signature JIMMYSGAME =
sig

  structure Seq : SEQUENCE

  type 'a seq = 'a Seq.seq

  type rules = (int * (int * int)) seq
  type target = int seq

  val minSteps : int * target * rules -> int option

end
