structure Tests =
struct

  (* Each test is (S, answer), where correctness is verified by
   * calling isValidHashtag S and comparing it with the answer provided.
   * The dictionary we are using for isWord is in support/words. *)
  val hashtagTests : (string * bool) list = [
      ("happy", true)
  ]

  type color = int
  type village = int * color

  (* Each test is (L, R, answer), where correctness is verified by calling
   * maxBridges (L, R) and comparing it with the answer provided. In both L
   * and R, the colors range from 0 to n - 1, where n is the length of L
   * and R. *)
  val frogBridgesTests : (village list * village list * int) list = [
      ([(0, 0), (1, 1)],
       [(1, 0), (0, 1)],
       1),
      ([(0, 0), (1, 1)],
       [(1, 1), (0, 0)],
       2)
  ]

  type target = int list
  type rule = (int * (int * int))
  (* Each rule is (x, y, z), which represents the rule x -> yz. *)
  val rules1 : rule list = [(1, (2, 3)), (2, (1, 2))]

  (* Each test is (init, target, rules, answer), where correctness is
   * verified by calling minSteps (init, target, rules) and comparing it
   * with the answer provided. *)
  val jimmysGameTests : (int * target * rule list * int option) list = [
      (1, [1, 2, 3], rules1, SOME(2))
  ]

end
