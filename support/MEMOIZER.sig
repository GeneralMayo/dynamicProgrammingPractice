signature MEMOIZER =
sig
  type argument
  val memoize : ((argument -> 'r) -> argument -> 'r) -> argument -> 'r
end
