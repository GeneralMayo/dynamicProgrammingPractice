signature HASHTAG =
sig

  structure Seq : SEQUENCE

  type 'a seq = 'a Seq.seq

  val isValidHashtag : string -> bool

end
