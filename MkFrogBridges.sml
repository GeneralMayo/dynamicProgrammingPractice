functor MkFrogBridges(structure Seq : SEQUENCE) : FROGBRIDGES =
struct
  structure Seq = Seq
  open Seq

  (* Remove when you're done! *)
  exception NotYetImplemented

  type color = int
  type village = int * color

  fun maxBridges (L, R) =
    raise NotYetImplemented
end
