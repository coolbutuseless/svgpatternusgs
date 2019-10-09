
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



#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# How bits are packed for simple patterns
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
pack_spec <- list(
  usgs_code      = list(type = 'choice' , nbits =  8, options = padded_usgs_codes),
  spacing        = list(type = 'scaled' , nbits =  4, max = 255),
  fill           = list(type = 'colour' , nbits =  8),
  angle          = list(type = 'scaled' , nbits =  4, max = 360, cyclical = TRUE),
  alpha          = list(type = 'scaled' , nbits =  8, max = 1)
)


defaults <- list(
  usgs_code = 601,
  spacing   = 20,
  fill      = '#ffffff',
  angle     = 0,
  alpha     = 1.0
)


#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#' Is the rgba_vec interpretable as a pattern?
#'
#' @param rgba_vec 4 element vector of RGBA values, each in the range [0, 255]
#'
#' @return logical value indicating whether or not thig RGBA colour is
#'         interpretable as a pattern in this package?
#'
#' @export
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
is_valid_pattern_encoding <- function(rgba_vec) {
  is_black <- function(vec) {
    vec[1] == 0 && vec[2] == 0 && vec[3] == 0
  }

  is_white <- function(vec) {
    vec[1] == 255 && vec[2] == 255 && vec[3] == 255
  }

  is_transparent <- function(vec) {
    vec[4] == 0
  }


  !(is_black(rgba_vec) || is_white(rgba_vec) || is_transparent(rgba_vec))
}


#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#' Encode a pattern as a hex colour
#'
#' @param ... parameters to
#'
#' @return Return a hex colour representing the parameters
#'
#' @import lofi
#' @importFrom utils modifyList
#' @export
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
encode_pattern_params_as_hex_colour <- function(...) {

  params <- list(...)

  values <- modifyList(defaults, params)
  int32  <- lofi::pack(values, pack_spec)
  lofi::int32_to_hex_colour(int32)
}



#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#' Create the pattern id for a given hex colour for this package
#'
#' @param rgba_vec 4 element RGBA colour vector. Each element in range [0, 255]
#'
#' @return character string to use as a pattern ID
#' @export
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
create_pattern_id_from_rgba_vec <- function(rgba_vec) {
  hex_colour <- lofi::rgba_vec_to_hex_colour(rgba_vec)
  int32      <- lofi::rgba_vec_to_int32(rgba_vec)
  params     <- lofi::unpack(int32, pack_spec)
  paste("usgs", params$usgs_code, substr(hex_colour, 2, 9), sep = "-")
}



#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#' Decode a 4-element RGBA colour vector as an SVG pattern
#'
#' @param rgba_vec 4 element RGBA colour vector. Each element in range [0, 255]
#'
#' @return minisvg object
#'
#' @import lofi
#' @export
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
decode_pattern_from_rgba_vec <- function(rgba_vec) {

  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # Need an int32 so we can unpack
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  hex_colour <- lofi::rgba_vec_to_hex_colour(rgba_vec)
  int32      <- lofi::rgba_vec_to_int32(rgba_vec)

  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  #unpack params and set a good default ID
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  params     <- lofi::unpack(int32, pack_spec)
  params$id  <- create_pattern_id_from_rgba_vec(rgba_vec)

  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # Create the pattern and return it
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  do.call(create_usgs_pattern, params)
}





if (FALSE) {
  library(htmltools)
  (hex_colour <- encode_pattern_params_as_hex_colour())
  pattern <- decode_pattern_from_rgba_vec(hex_colour_to_rgba_vec(hex_colour))

  pattern

}


