functor MkJimmysGame(structure Seq : SEQUENCE) : JIMMYSGAME =
struct
  structure Seq = Seq
  open Seq

  (* Remove when you're done! *)
  exception NotYetImplemented

  type rules = (int * (int * int)) seq
  type target = int seq

  fun minSteps (init, S, R) =
    raise NotYetImplemented
end
