(**
 * 210lib/TreeSequence.sml
 *
 * Implements SEQUENCE with weight balanced trees
 *)
structure TreeSequence : SEQUENCE =
struct
  open Primitives
  exception NYI

  (* alpha is the balance criteria.  For every node one side cannot
     be more than an alpha factor larger than the other side *)
  val alpha = 2;

  type 'a ord = 'a * 'a -> order

  datatype 'a tree = T0
                   | T1 of 'a
                   | T2 of int * 'a tree * 'a tree  (* T2 keeps the size *)
  type 'a t = 'a tree
  type 'a seq = 'a t

  (*datatype 'a treeview = EMPTY | ELT of 'a | NODE of 'a seq * 'a seq*)
  datatype 'a listview = NIL | CONS of 'a * 'a seq

  exception Range
  exception Size

  fun length S =
     case S of
       T0 => 0
     | T1(_) => 1
     | T2(n,_,_) => n

  fun empty _ = T0
  fun singleton x = T1(x)

  (* rebalances with a single or double rotation if need be
     this is the only place that alpha is used *)
  fun makeNode(L,R) =
    let
       val ln = length L
       val rn = length R
       val n = ln + rn
    in
       if (ln > alpha * rn) then
         case L of
           T2(_,LL,LR) =>
              if ((alpha+1)*(length LL) >= n)
              then T2(n,LL,T2(length LR + rn,LR,R)) (* single rotation right *)
              else  (* double rotation *)
                case LR of
                   T2(_,LRL,LRR) => T2(n,T2(length LL + length LRL,LL,LRL),
		                         T2(length LRR + rn,LRR,R))
      else if (rn > alpha * ln) then
         case R of
           T2(_,RL,RR) =>
              if ((alpha+1)*(length RR) >= n)
              then T2(n,T2(ln + length RL,L,RL),RR) (* single rotation left *)
              else (* double rotation *)
                case RL of
                   T2(_,RLL,RLR) => T2(n,T2(ln + length RLL,L,RLL),
		                         T2(length RLR + length RR,RLR,RR))
      else T2(n,L,R) (* no rotation *)
    end

  fun append (s, t) =
     case (s,t) of
       (T0,_) => t
     | (_,T0) => s
     | _      =>
       let
          val ls = length s
          val lt = length t
       in
          if (ls > 2*lt) then
            case s of T2(_,Ls,Rs) => makeNode(Ls,append(Rs,t))
          else if (lt > 2*ls) then
            case t of T2(_,Lt,Rt) => makeNode(append(s,Lt),Rt)
          else T2(ls + lt, s, t)
       end

  fun map f S =
     case S of
        T0 => T0
      | T1(v) => T1(f(v))
      | T2(s,L,R) =>
          let val (L',R') = par(fn () => map f L, fn () => map f R)
	  in T2(s,L',R')
	  end

  fun tabulate f n =
    let
       fun tab(s,l) =
         if (l = 1) then singleton(f(s))
         else
           let
              val half = l div 2
              val (L,R) = par(fn () => tab(s,half),
	                      fn () => tab(s+half,l-half))
           in append(L,R)
           end
    in
      if n < 0 then raise Size
      else if n = 0 then empty ()
      else tab(0,n)
    end

  fun nth S i =
     case S of
       T0 => raise Range
     | T1(x) => if (i=0) then x
                else raise Range
     | T2(s,L,R) =>
        let val l = length L
        in
          if (i >= l) then nth R (i-l)
          else nth L i
	end

  fun toString f s =
      "<" ^ String.concatWith "," (List.tabulate (length s, f o nth s)) ^ ">"

  fun fromList l =
     let
       fun flist(nil,_) = (T0,nil)
         | flist(a::r,n) =
         if (n=1) then (T1(a),r)
         else
           let val h = n div 2
               val (SL,rl) = flist(a::r,h)
               val (SR,rr) = flist(rl,n-h)
           in (T2(n,SL,SR),rr) end
        val (r,_) = flist(l,List.length l)
      in
          r
      end

  val % = fromList

  fun cut S i =
    case S of
      T0 => (T0,T0)
    | T1(x) => if (i = 0) then (T0,S)
               else (S,T0)
    | T2(s,L,R) =>
        let val l = length L
        in
          if (i = l) then (L,R)
          else if (i < l) then
            let val (LL,LR) = cut L i
            in (LL,append(LR,R))
            end
          else
            let val (RL,RR) = cut R (i-l)
            in (append(L,RL),RR)
            end
	end

  fun subseq S (i, len') =
      if len' < 0 then raise Size
      else if i < 0 orelse i+len' > (length S) then raise Range
      else
        let
          val (_,R) = cut S i
          val (L,_) = cut R len'
        in L end

  fun take n s = subseq s (0, n)
  fun drop n s = subseq s (n, length s - n)

  fun showl T0 = NIL
    | showl s = CONS (nth s 0, drop 1 s)

  (*fun showt s =
      case s
        of T0 => EMPTY
         | T1(v) => ELT(v)
         | T2(n,_,_) =>
             let val half = n div 2
               val (L,R) = cut s half
             in NODE (L, R) end*)

  fun rev s =
      case s
        of T0 => T0
         | T1(v) => T1(v)
         | T2(n,L,R) =>
             let val (L',R') = par(fn () => rev R, fn () => rev L)
	     in T2(n, L', R')
	     end

  fun iterh f b s =
      let
        fun iterh' s (old, cur) =
            case showl s
              of NIL => (rev (fromList old), cur)
               | CONS (x, xs) => iterh' xs (cur::old, f (cur, x))
      in iterh' s ([], b)
      end

  fun iterhi f b s =
    let val (partials, final) = iterh f b s
    in drop 1 (append (partials, singleton final))
    end

  fun iter f b s = #2 (iterh f b s)
  fun toList s = iter (fn (l,x) => x::l) [] (rev s)

  fun merge cmp (s, t) =
      let
        (* Sequential merge. Pretend it's parallel! *)
        fun merge' [] t = t
          | merge' s [] = s
          | merge' (x::xs) (y::ys) =
            if cmp (y, x) = LESS
            then y::merge' (x::xs) ys
            else x::merge' xs (y::ys)

      in fromList (merge' (toList s) (toList t))
      end

  fun sort cmp s =
    case length s of
      (0 | 1) => s
    | n => merge cmp (par (fn () => sort cmp (take (n div 2) s),
                           fn () => sort cmp (drop (n div 2) s)))

  fun enum s = tabulate (fn i => (i, nth s i)) (length s)
  fun mapIdx f = map f o enum

  fun zipWith f s t =
      tabulate (fn i => f (nth s i, nth t i)) (Int.min (length s, length t))

  fun unzipWith (spl : 'a -> 'b * 'c) s =
      let
        val n = length s
        val s' = map spl s
      in (tabulate (#1 o nth s') n, tabulate (#2 o nth s') n)
      end

  fun zip s t = zipWith (fn x => x) s t
  fun unzip s = unzipWith (fn x => x) s

  fun reduce f b s =
      case length s
        of 0 => b
         | 1 => f (b, nth s 0)
         | n => let
                  fun contract i =
                      if i = n div 2 then nth s (2*i)
                      else f (nth s (2*i), nth s (2*i+1))
                in reduce f b (tabulate contract ((n+1) div 2))
                end

  (* scan (1) combines base case at bottom of recursion *)
  fun scan f b s =
      case length s
        of 0 => (empty (), b)
         | 1 => (singleton b, f (b, nth s 0))
         | n =>
           let
             fun contract i =
                 if i = n div 2 then nth s (2*i)
                 else f (nth s (2*i), nth s (2*i+1))
             val s' = tabulate contract ((n+1) div 2)
             val (r, res) = scan f b s'
             fun expand i =
                 if i mod 2 = 0 then nth r (i div 2)
                 else f (nth r (i div 2), nth s (i-1))
           in (tabulate expand n, res)
           end

  local
    fun scan' f S =
        if length S = 1 then (empty (), nth S 0)
        else let
          val n = length S
          fun contract i =
              if i = n div 2 then nth S (2*i)
              else f (nth S (2*i), nth S (2*i + 1))
          val S' = tabulate contract ((n+1) div 2)
          val (R, res) = scan' f S'
          fun expand 0 = nth S 0
            | expand i =
              if i mod 2 = 1 then nth R (i div 2)
              else f (nth R ((i-1) div 2), nth S i)
        in (tabulate expand (n-1), res)
        end
  in
    (* scan (2) combines base case after recursion *)
    fun scan f b S =
        if length S = 0 then (empty (), b)
        else let
          val (R, res) = scan' f S
          val R' = map (fn x => f (b, x)) R
        in (append (singleton b, R'), f (b, res))
        end
  end

  fun scani f b s =
      let val (r, res) = scan f b s
      in drop 1 (append (r, singleton res))
      end

  fun flatten ss = reduce append (empty()) ss

  fun filter p s =
     case s of
       T0 => T0
     | T1(v) => if p(v) then s else T0
     | T2(n,L,R) =>
         let
            val (L',R') = par(fn () => filter p L,
	                      fn () => filter p R)
         in
            append(L', R')
         end

  fun filterIdx p =
      map (fn (_, x) => x) o (filter p) o enum

  fun equal cmp (s1,s2) =
      length s1 = length s2 andalso
      reduce (fn (x,y) => x andalso y) true (zipWith cmp s1 s2)

  fun argmax cmp s =
      if length s = 0 then raise Range
      else let
        fun best (i, j) =
            if cmp (nth s j, nth s i) = GREATER then j else i
      in reduce best 0 (tabulate (fn i => i) (length s))
      end

  fun inject idx s = raise NYI
  fun update (i, x) = inject (singleton (i, x))

  fun collect cmp s =
      let
        val n = length s
        val (ks, vs) = unzip (sort (fn ((x,_), (y,_)) => cmp (x,y)) s)

        fun dk (0, _) = true
          | dk (i, k) = cmp (nth ks (i-1), k) <> EQUAL

        val starts = map (fn (i, _) => i) (filter dk (enum ks))
        val lengths = zipWith op- (drop 1 (append (starts, %[n]))) starts

        fun make (i, len) = (nth ks i, subseq vs (i, len))
      in zipWith make starts lengths
      end

  fun collate cmp (s1, s2) =
      case (showl s1, showl s2)
        of (NIL, NIL) => EQUAL
         | (NIL, _) => LESS
         | (_, NIL) => GREATER
         | (CONS (x, xs), CONS (y, ys)) =>
           case cmp (x, y)
             of EQUAL => collate cmp (xs, ys)
              | ord => ord
end
