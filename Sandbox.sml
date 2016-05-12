(* Write anything you want in the structure below. To use it at the REPL, do
 * - CM.make "sandbox.cm"; open Sandbox; *)
structure Sandbox =
struct
  structure Seq = ArraySequence

  (* your code, from MkHashtag.sml *)
  structure Hashtag : HASHTAG = MkHashtag (structure Seq = Seq
                                           structure Dict = SimpleDictionary)

  (* from MkFrogBridges.sml *)
  structure FrogBridges : FROGBRIDGES = MkFrogBridges (structure Seq = Seq)

  (* from MkJimmysGame.sml *)
  structure JimmysGame : JIMMYSGAME = MkJimmysGame (structure Seq = Seq)

  (* from MkSeamFind.sml *)
  structure SeamFind : SEAMFIND = MkSeamFind(structure Seq = Seq)

  (* For your convenience... *)
  fun vToS (x, y) =
    String.concat [ "(", Int.toString x, ",", Int.toString y, ")" ]

  val villagesToString = Seq.toString vToS

  fun rToS (x, (y, z)) =
    String.concat [ "(", Int.toString x, ",(",
                    Int.toString y, ",",
                    Int.toString z, "))" ]
  val rulesToString = Seq.toString rToS

  fun oToS NONE = "NONE"
    | oToS (SOME x) = String.concat [ "SOME(", Int.toString x, ")" ]
  (* An example test *)
  fun example () =
    let
      val is_hashtag = Hashtag.isValidHashtag "imanagedthelab"
      val _ = print (Bool.toString is_hashtag ^ "\n")

      val villages1 = Seq.%[(3, 1), (4, 2), (2, 0)]
      val _ = print (villagesToString villages1 ^ "\n")
      val villages2 = Seq.%[(7, 2), (3, 1), (~2, 0)]
      val _ = print (villagesToString villages2 ^ "\n")
      val max_bridges = FrogBridges.maxBridges (villages1, villages2)
      val _ = print (Int.toString max_bridges ^ "\n")

      val target = Seq.%[1, 3, 5, 7]
      val rules = Seq.%[(2, (1, 3)), (2, (3, 5)), (4, (2, 6)),
                        (6, (3, 5)), (6, (5, 7))]
      val _ = print (rulesToString rules)
      val min_steps = JimmysGame.minSteps (4, target, rules)
      val _ = print (oToS min_steps ^ "\n")
    in
      ()
    end
end
