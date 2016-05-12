structure SimpleDictionary : DICTIONARY
=
struct
  structure T = MkTreapTable(structure Key = StringElt)
  structure Seq = T.Seq
  structure S = T.Set
  open S

  type dict = set

  fun fromFile file =
      let
        val ins = TextIO.openIn file
        fun readlines ins =
            case TextIO.inputLine ins of
              SOME line =>
              String.substring(line, 0, String.size line - 1) :: readlines ins
            | NONE => []
        val wordlist = readlines ins before TextIO.closeIn ins
        val wordseq = Seq.fromList wordlist
        val wordset = S.fromSeq wordseq
      in
        wordset
      end

  val engdict = fromFile "support/words"

  fun isWord x =
      let
        val lowerx = String.implode (List.map (Char.toLower) (String.explode x))
      in
        S.find engdict lowerx
      end
end
