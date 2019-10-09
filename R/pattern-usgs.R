
empty_pattern             <- "<pattern id='null'></pattern>"

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#' Read an svg pattern from the zipped file given the USGS code
#'
#' @param usgs_code a USGS code for a pattern
#'
#' @return svg pattern object
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
read_zipped_pattern_by_code <- function(usgs_code = 601) {
  filename <- paste0(usgs_code, ".svg")
  if (!filename %in% all_usgs_filenames) {
    warning("No such USGS pattern: ", usgs_code)
    return(empty_pattern)
  }

  zip_file <- system.file("patterns", "usgs_svg_patterns.zip", package = "svgpatternusgs")

  con      <- unz(zip_file, filename)
  on.exit(close(con))
  lines    <- readLines(con)
  pattern  <- paste(lines, collapse = "\n")

  pattern
}


#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#' Create usgs pattern
#'
#' @param usgs_code USGS code for a pattern
#' @param spacing size of pattern
#' @param fill fill colour
#' @param id id to use for pattern. default: NULL means to generate automatically
#' @param alpha default: 1.0 (opaque)
#' @param angle angle
#'
#' @return character string containing an svg <pattern>
#'
#' @export
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
create_usgs_pattern <- function(usgs_code = 601,
                                spacing   = 20,
                                fill      = '#ffffff',
                                alpha     = 1.0,
                                angle     = 0,
                                id        = NULL) {

  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # Try and create a pattern 'id' if none has been given
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  if (is.null(id)) {
    id <- paste("usgs", usgs_code, substr(fill, 2, 19),
                alpha, angle, sep="-")
  }

  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # Create the pattern
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  pattern <- read_zipped_pattern_by_code(usgs_code)

  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # Modify the pattern template with the users options
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  pattern <- modify_usgs_pattern(pattern,
                                 width = spacing,
                                 alpha = alpha,
                                 fill  = fill,
                                 angle = angle)


  pattern <- minisvg::parse_svg_elem(pattern, as_pattern = TRUE)

  pattern$attribs$id <- id
  pattern
}

