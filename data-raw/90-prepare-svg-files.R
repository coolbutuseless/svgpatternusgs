
rm(list=ls())

library(xml2)

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# filenames for the raw SVG patterns
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
svg_files <- list.files("data-raw/geologic-patterns/assets/svg/", full.names = TRUE)

svg_files <- svg_files[grepl("-K", svg_files) | nchar(basename(svg_files))==7]
svg_file <- svg_files[1]

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# 01 - Whitespace tidy
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
outdir01 <- "data-raw/01-svg-whitespace"
dir.create(outdir01, showWarnings = FALSE)

for (svg_file in svg_files) {
  svg_text <- readLines(svg_file)
  svg_text <- stringr::str_trim(svg_text)
  svg_text <- svg_text[svg_text != '']
  svg_text <- gsub("\\s+", " ", svg_text)

  outfile <- file.path(outdir01, basename(svg_file))
  svg_obj <- xml2::read_xml(paste(svg_text, collapse="\n"))
  xml2::write_xml(svg_obj, outfile)
}




#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# 02 - Convert to raw <pattern></pattern> rather than <svg></svg>
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
svg_files <- list.files(outdir01, full.names = TRUE)
svg_file  <- svg_files[4]
outdir02  <- "data-raw/02-svg-pattern-raw"
dir.create(outdir02, showWarnings = FALSE)


#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# Build a generic rectangle to use as the background for every pattern
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# bg_rect <- xml2::read_xml("<rect width='100%' height='100%' style='fill:#ffffff; fill-opacity:1.00; stroke:none;'/>")


for (svg_file in svg_files) {

  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # Read the SVG object, take note of its attributes (to apply to pattern later)
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  svg_obj   <- read_xml(svg_file)
  svg_attrs <- xml_attrs(svg_obj)

  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # Every pattern needs a viewbox so we can scale it later for display
  # by maniupulating the 'width' and 'height' attributes.
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  if (!'viewBox' %in% names(svg_attrs)) {
    svg_attrs['viewBox'] <- as.character(glue::glue("0 0 {svg_attrs['width']} {svg_attrs['height']}"))
  }

  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # throw away the <svg> wrapper and just keep the inner
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  g_obj     <- xml_children(svg_obj)

  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # Create an empty pattern with the correct attributes
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  id <- gsub("-K", "", tools::file_path_sans_ext(basename(svg_file)))
  id <- paste0("usgs-", id)

  # patternTransform='rotate({angle} 0 0)'

  pattern_attrs <- c()
  pattern_attrs['id'] <- id
  pattern_attrs['patternUnits']     <- 'userSpaceOnUse'
  pattern_attrs['patternTransform'] <- 'rotate(0 0 0)'
  pattern_attrs <- c(pattern_attrs, svg_attrs[intersect(c('x', 'y', 'width', 'height', 'viewBox'), names(svg_attrs))])
  pattern_node <- xml2::read_xml("<pattern></pattern>")
  xml_set_attrs(pattern_node, pattern_attrs)


  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # some files are missing a BG rect
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  lines <- readLines(svg_file)
  rects <- grep("rect.*?fill:none", lines)
  if (length(rects) == 0) {
    # This file is missing a bg rect
    message("Adding bg_rect for: ", svg_file)

    viewbox <- pattern_attrs[['viewBox']]
    viewbox <- strsplit(viewbox, "\\s+")[[1]]  # x, y, w, h
    bg_rect <- glue::glue('<rect x="{viewbox[1]}" y="{viewbox[2]}" style="fill:none; stroke:none;" width="{viewbox[3]}" height="{viewbox[4]}"/>')
    bg_rect <- xml2::read_xml(bg_rect)
    xml_add_child(pattern_node, bg_rect)
  }

  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # Copy across all the svg nodes into this pattern
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  for (x in g_obj) {
    xml_add_child(pattern_node, x)
  }

  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # Strip the default 'namespace' attribute and output to file.
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  outfile <- file.path(outdir02, basename(svg_file))
  outfile <- gsub("-K", "", outfile)
  write_xml(xml_ns_strip(pattern_node),
            outfile,
            options = c('format', 'no_declaration'))

}




#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# isolated rect corrections
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
filename <- "data-raw/02-svg-pattern-raw/104.svg"
svg_text <- readLines(filename)
svg_text <- gsub('<path fill="none" d="M0 0h33.5v33.5H0z"/>',
                 '', svg_text)
writeLines(svg_text, filename)

filename <- "data-raw/02-svg-pattern-raw/135.svg"
svg_text <- readLines(filename)
svg_text <- gsub('<path fill="none" d="M0 0h53.18v53.6H0z"/>',
                 '', svg_text)
writeLines(svg_text, filename)

filename <- "data-raw/02-svg-pattern-raw/202.svg"
svg_text <- readLines(filename)
svg_text <- gsub('<path d="M0 0h73.86v73.5H0z"/>',
                 '', svg_text)
writeLines(svg_text, filename)


filename <- "data-raw/02-svg-pattern-raw/215.svg"
svg_text <- readLines(filename)
svg_text <- gsub('<rect x="0" y="-74.5" style="fill-rule:evenodd;clip-rule:evenodd;fill:none;" width="74.499" height="74.499"/>',
                 '<rect x="0" y="-74.5" style="fill-rule:evenodd;clip-rule:evenodd;fill:none;stroke:none;" width="74.499" height="74.499"/>', svg_text)
writeLines(svg_text, filename)



filename <- "data-raw/02-svg-pattern-raw/218.svg"
svg_text <- readLines(filename)
svg_text <- gsub('<rect x="1" y="-73.66" style="fill-rule:evenodd;clip-rule:evenodd;fill:none;" width="72" height="72"/>',
                 '<rect x="1" y="-73.66" style="fill-rule:evenodd;clip-rule:evenodd;fill:none;stroke:none;" width="72" height="72"/>', svg_text)
writeLines(svg_text, filename)


filename <- "data-raw/02-svg-pattern-raw/219.svg"
svg_text <- readLines(filename)
svg_text <- gsub('<rect x="1" y="-79.444" style="fill-rule:evenodd;clip-rule:evenodd;fill:none;" width="77.784" height="77.785"/>',
                 '<rect x="1" y="-79.444" style="fill-rule:evenodd;clip-rule:evenodd;fill:none;stroke:none;" width="77.784" height="77.785"/>', svg_text)
writeLines(svg_text, filename)


filename <- "data-raw/02-svg-pattern-raw/229.svg"
svg_text <- readLines(filename)
svg_text <- gsub('<rect x="1" y="-75.088" style="fill-rule:evenodd;clip-rule:evenodd;fill:none;" width="73.428" height="73.428"/>',
                 '<rect x="1" y="-75.088" style="fill-rule:evenodd;clip-rule:evenodd;fill:none;stroke:none;" width="73.428" height="73.428"/>', svg_text)
writeLines(svg_text, filename)


filename <- "data-raw/02-svg-pattern-raw/230.svg"
svg_text <- readLines(filename)
svg_text <- gsub('<rect x="0" y="-80.646" style="fill-rule:evenodd;clip-rule:evenodd;fill:none;" width="80.646" height="80.646"/>',
                 '<rect x="0" y="-80.646" style="fill-rule:evenodd;clip-rule:evenodd;fill:none;stroke:none;" width="80.646" height="80.646"/>', svg_text)
writeLines(svg_text, filename)


filename <- "data-raw/02-svg-pattern-raw/231.svg"
svg_text <- readLines(filename)
svg_text <- gsub('<rect x="0" y="-90.305" style="fill-rule:evenodd;clip-rule:evenodd;fill:none;" width="90.306" height="90.305"/>',
                 '<rect x="0" y="-90.305" style="fill-rule:evenodd;clip-rule:evenodd;fill:none;stroke:none;" width="90.306" height="90.305"/>', svg_text)
writeLines(svg_text, filename)


filename <- "data-raw/02-svg-pattern-raw/402.svg"
svg_text <- readLines(filename)
svg_text <- gsub('<rect x="0" y="0" style="fill:none;" width="71.339" height="71.301"/>',
                 '<rect x="0" y="0" style="fill:none;stroke:none;" width="71.339" height="71.301"/>', svg_text)
svg_text <- gsub('<path fill="none" d="M0 0h71.34v71.3H0z"/>',
                 '', svg_text)
writeLines(svg_text, filename)



filename <- "data-raw/02-svg-pattern-raw/427.svg"
svg_text <- readLines(filename)
svg_text <- gsub('<rect x="1" y="-8.924" style="fill:none;" width="7.924" height="7.924"/>',
                 '<rect x="1" y="-8.924" style="fill:none;stroke:none;" width="7.924" height="7.924"/>', svg_text)
writeLines(svg_text, filename)


filename <- "data-raw/02-svg-pattern-raw/602.svg"
svg_text <- readLines(filename)
svg_text <- gsub('<rect x="2.077" y="-55.938" style="fill:none;" width="54.125" height="54.125"/>',
                 '<rect x="2.077" y="-55.938" style="fill:none; stroke:none;" width="54.125" height="54.125"/>', svg_text)
writeLines(svg_text, filename)


filename <- "data-raw/02-svg-pattern-raw/612.svg"
svg_text <- readLines(filename)
svg_text <- gsub('<rect y="-54.125" style="fill:none;" width="54.125" height="54.125"/>',
                 '<rect y="-54.125" style="fill:none;stroke:none;" width="54.125" height="54.125"/>', svg_text)
writeLines(svg_text, filename)


filename <- "data-raw/02-svg-pattern-raw/630.svg"
svg_text <- readLines(filename)
svg_text <- gsub('<rect x="0.043" y="-54.125" style="fill:none;" width="54.125" height="54.125"/>',
                 '<rect x="0.043" y="-54.125" style="fill:none;stroke:none;" width="54.125" height="54.125"/>', svg_text)
writeLines(svg_text, filename)


filename <- "data-raw/02-svg-pattern-raw/658.svg"
svg_text <- readLines(filename)
svg_text <- gsub('<rect y="-54.125" width="54.125" height="54.125"/>',
                 '<rect y="-54.125" width="54.125" height="54.125" style="fill:none;stroke:none;"/>', svg_text)
writeLines(svg_text, filename)


filename <- "data-raw/02-svg-pattern-raw/659.svg"
svg_text <- readLines(filename)
svg_text <- gsub('<rect x="0.107" y="-54.125" width="54.125" height="54.125"/>',
                 '<rect x="0.107" y="-54.125" width="54.125" height="54.125" style="fill:none;stroke:none;"/>', svg_text)
writeLines(svg_text, filename)


filename <- "data-raw/02-svg-pattern-raw/668.svg"
svg_text <- readLines(filename)
svg_text <- gsub('<rect y="-54.125" style="fill:none;" width="54.125" height="54.125"/>',
                 '<rect y="-54.125" style="fill:none;stroke:none;" width="54.125" height="54.125"/>', svg_text)
writeLines(svg_text, filename)


filename <- "data-raw/02-svg-pattern-raw/676.svg"
svg_text <- readLines(filename)
svg_text <- gsub('<rect y="-54.125" style="fill:none;" width="54.125" height="54.125"/>',
                 '<rect y="-54.125" style="fill:none;stroke:none;" width="54.125" height="54.125"/>', svg_text)
writeLines(svg_text, filename)


filename <- "data-raw/02-svg-pattern-raw/680.svg"
svg_text <- readLines(filename)
svg_text <- gsub('<rect x="0" y="-48.712" style="fill:none;" width="48.712" height="48.712"/>',
                 '<rect x="0" y="-48.712" style="fill:none;stroke:none;" width="48.712" height="48.712"/>', svg_text)
writeLines(svg_text, filename)


filename <- "data-raw/02-svg-pattern-raw/681.svg"
svg_text <- readLines(filename)
svg_text <- gsub('<rect y="-54.125" style="fill:none;" width="54.125" height="54.125"/>',
                 '<rect y="-54.125" style="fill:none;stroke:none;" width="54.125" height="54.125"/>', svg_text)
writeLines(svg_text, filename)


filename <- "data-raw/02-svg-pattern-raw/684.svg"
svg_text <- readLines(filename)
svg_text <- gsub('<rect y="-41.881" style="fill:none;" width="41.881" height="41.881"/>',
                 '<rect y="-41.881" style="fill:none;stroke:none;" width="41.881" height="41.881"/>', svg_text)
writeLines(svg_text, filename)


filename <- "data-raw/02-svg-pattern-raw/685.svg"
svg_text <- readLines(filename)
svg_text <- gsub('<rect y="-54.125" style="fill:none;" width="54.125" height="54.125"/>',
                 '<rect y="-54.125" style="fill:none;stroke:none;" width="54.125" height="54.125"/>', svg_text)
writeLines(svg_text, filename)






if (FALSE) {
  library(svgpatternusgs)
  moar <- list.files(outdir02, full.names = TRUE, pattern = "*svg")
  pattern <- svgpatternusgs:::read_pattern(moar[6])


  pattern_files <- moar[1:25]
  patterns <- purrr::map(pattern_files, svgpatternusgs:::read_pattern)
}

















