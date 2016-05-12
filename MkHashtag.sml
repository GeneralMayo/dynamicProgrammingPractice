functor MkHashtag(structure Seq : SEQUENCE
                  structure Dict : DICTIONARY) : HASHTAG =
struct
  structure Seq = Seq
  open Seq
  structure Dict = Dict
  open Dict

  (* Remove when you're done! *)
  exception NotYetImplemented

  fun isValidHashtag S =
    raise NotYetImplemented
end
