

padded_usgs_codes <- c(
  101L, 102L, 103L, 104L, 105L, 106L, 114L, 116L, 117L, 118L,
  119L, 120L, 121L, 122L, 123L, 124L, 132L, 134L, 135L, 136L, 137L,
  201L, 202L, 204L, 206L, 207L, 214L, 215L, 216L, 217L, 218L, 219L,
  226L, 228L, 229L, 230L, 231L, 232L, 233L, 301L, 302L, 303L, 304L,
  305L, 306L, 313L, 314L, 315L, 316L, 317L, 318L, 319L, 327L, 328L,
  330L, 331L, 401L, 402L, 403L, 405L, 406L, 411L, 412L, 416L, 417L,
  418L, 419L, 420L, 423L, 424L, 427L, 428L, 429L, 430L, 431L, 432L,
  433L, 434L, 435L, 436L, 521L, 522L, 523L, 524L, 591L, 592L, 593L,
  594L, 595L, 601L, 602L, 603L, 605L, 606L, 607L, 608L, 609L, 610L,
  611L, 612L, 613L, 614L, 616L, 617L, 618L, 619L, 620L, 621L, 622L,
  623L, 624L, 625L, 626L, 627L, 628L, 629L, 630L, 631L, 632L, 633L,
  634L, 635L, 636L, 637L, 638L, 639L, 640L, 641L, 642L, 643L, 644L,
  645L, 646L, 647L, 648L, 649L, 650L, 651L, 652L, 653L, 654L, 655L,
  656L, 657L, 658L, 659L, 660L, 661L, 662L, 663L, 664L, 665L, 666L,
  667L, 668L, 669L, 670L, 671L, 672L, 673L, 674L, 675L, 676L, 677L,
  678L, 679L, 680L, 681L, 682L, 683L, 684L, 685L, 686L, 701L, 702L,
  703L, 704L, 705L, 706L, 707L, 708L, 709L, 710L, 711L, 712L, 713L,
  714L, 715L, 716L, 717L, 719L, 720L, 721L, 722L, 723L, 724L, 725L,
  726L, 727L, 728L, 729L, 730L, 731L, 732L, 733L, 101L, 102L, 103L,
  104L, 105L, 106L, 114L, 116L, 117L, 118L, 119L, 120L, 121L, 122L,
  123L, 124L, 132L, 134L, 135L, 136L, 137L, 201L, 202L, 204L, 206L,
  207L, 214L, 215L, 216L, 217L, 218L, 219L, 226L, 228L, 229L, 230L,
  231L, 232L, 233L, 301L, 302L, 303L, 304L, 305L, 306L, 313L, 314L,
  315L, 316L, 317L, 318L)



empty_pattern             <- "<pattern id='null'></pattern>"

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#' Read an svg pattern from the zipped file given the USGS code
#'
#' This package comes with all SVG stored in a zip file.  This function takes
#' a USGS code and extracts that particular SVG from the zip file.
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
#' Create an SVG pattern from the USGS library
#'
#' @param usgs_code USGS code for a pattern
#' @param spacing size of pattern
#' @param fill fill colour
#' @param id id to use for pattern. default: NULL means to generate automatically
#' @param alpha default: 1.0 (opaque)
#' @param angle angle
#'
#' @return minisvg::SVGPattern object
#'
#' @export
#'
#'
#' @examples
#' \dontrun{
#' # Create an SVG document
#' library(minisvg)
#' doc   <- minisvg::svg_doc()
#'
#' # Create the pattern and add to the SVG definitions
#' my_pattern <- create_usgs_pattern(usgs_code = 601, spacing = 100)
#' doc$defs(my_pattern)
#'
#' # Create a rectangle with the animation
#' rect  <- stag$rect(
#'   x      = "10%",
#'   y      = "10%",
#'   width  = "80%",
#'   height = "80%",
#'   stroke = 'black',
#'   fill   = my_pattern
#' )
#'
#' # Add this rectangle to the document, show the SVG text, then render it
#' doc$append(rect)
#' doc
#' doc$show()
#' }
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

