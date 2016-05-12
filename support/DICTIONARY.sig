signature DICTIONARY =
sig
  structure S : ORDSET where Key = StringElt
  type dict = S.set

  val engdict : dict
  val isWord : string -> bool
end
