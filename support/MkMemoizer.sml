functor MkMemoizer(structure Argument : HASHKEY) : MEMOIZER = 
struct
  (* Quietly overlook this line.  You can do it.  I believe in you. *)
  structure Table = MkTreapTable(structure Key = Argument)

  type argument = Argument.t

  fun memoize (f : (argument -> 'r) -> argument -> 'r) : argument -> 'r = 
    let
      val cache = ref (Table.empty ())
      fun memoized (a : argument) =
        case Table.find (!cache) a of
          SOME r => r
        | NONE => 
          let
            val r = f memoized a
            val _ = (cache := Table.insert (!cache, (a, r)))
          in
            r
          end
    in
      memoized
    end
end
