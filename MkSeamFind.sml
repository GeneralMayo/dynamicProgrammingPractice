functor MkSeamFind(structure Seq : SEQUENCE) : SEAMFIND =
struct
  structure Seq = Seq
  open Seq

  (* Remove when you're done! *)
  exception NotYetImplemented

  type pixel = { r : real, g : real, b : real }
  type image = { width : int, height : int, data : pixel seq seq }
  type gradient = real

  fun findSeam G =
    raise NotYetImplemented
end
