signature FROGBRIDGES =
sig

  structure Seq : SEQUENCE

  type 'a seq = 'a Seq.seq

  type color = int
  type village = int * color

  val maxBridges : village seq * village seq -> int

end
