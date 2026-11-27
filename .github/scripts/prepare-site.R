# pkgdown 2.0 on Ubuntu emits a local MathJax URL and a mislabeled search field.
pages <- list.files("docs", pattern = "[.]html$", recursive = TRUE, full.names = TRUE)
for (page in pages) {
  html <- xml2::read_html(page)
  fields <- xml2::xml_find_all(html, "//input[@id='search-input']")
  math <- xml2::xml_find_all(html, "//script[@src='file:///usr/share/javascript/mathjax/MathJax.js']")
  if (length(fields)) xml2::xml_set_attr(fields, "aria-label", "Search documentation")
  if (length(math)) {
    xml2::xml_set_attr(math, "src", "https://cdnjs.cloudflare.com/ajax/libs/mathjax/2.7.5/MathJax.js")
    xml2::xml_set_attr(math, "integrity", "sha384-3lJUsx1TJHt7BA4udB5KPnDrlkO8T6J6v/op7ui0BbCjvZ9WqV4Xm6DTP6kQ/iBH")
  }
  stopifnot(!length(xml2::xml_find_all(html, "//*[@src and starts-with(@src, 'file:')]")))
  if (length(fields) || length(math)) xml2::write_html(html, page)
}
home <- xml2::read_html("docs/index.html")
stopifnot(length(xml2::xml_find_all(home, "//input[@aria-label='Search documentation']")) == 1L)

# Search results must resolve inside this Pages project, including from nested pages.
site <- sub("/$", "", yaml::read_yaml("_pkgdown.yml")$url)
prefix <- sub("^https://[^/]+", "", site)
index <- "docs/search.json"
entries <- jsonlite::read_json(index)
stopifnot(length(entries) > 0)
for (i in seq_along(entries)) {
  path <- entries[[i]]$path
  path <- sub(paste0(site, "/"), "", path, fixed = TRUE)
  if (startsWith(path, paste0(prefix, "/"))) path <- substring(path, nchar(prefix) + 2L)
  path <- sub("^/", "", path)
  stopifnot(file.exists(file.path("docs", path)))
  entries[[i]]$path <- paste0(prefix, "/", path)
}
jsonlite::write_json(entries, index, auto_unbox = TRUE, null = "null")
