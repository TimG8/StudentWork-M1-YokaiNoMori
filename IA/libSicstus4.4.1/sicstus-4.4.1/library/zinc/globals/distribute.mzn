/** @group globals.counting
  Requires that \a card[\p i] is the number of occurences of \a value[\p i] in
  \a base. The values in \a value need not be distinct.
*/
predicate distribute_sicstus(array[int] of var int: card,
                             array[int] of var int: value,
			     array[int] of var int: base);

predicate distribute(array[int] of var int: card,
                     array[int] of var int: value,
                     array[int] of var int: base) =
    assert(index_set(card) == index_set(value),
        "distribute: card and value arrays must have identical index sets",
	distribute_sicstus(card, value, base)
    );
