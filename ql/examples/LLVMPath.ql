// used against https://github.com/apple/llvm-project/tree/b73bab42a101a29a1e178d618bb8448d9a423b6e
// to investigate and confirm a potential invalidation in lld

import cpp
import trailofbits.itergator.iterators
import trailofbits.itergator.invalidations.Destructor
import trailofbits.itergator.invalidations.STL

from Invalidator i, InvalidatorT i1, InvalidatorT i2, InvalidatorT i3, InvalidatorT i4, InvalidatorT i5, InvalidatorT i6, InvalidatorT i7, InvalidatorT i8, InvalidatorT i9, InvalidatorT i10, InvalidatorT i11, Invalidation inv
where i.getTarget().hasName("handleUndefined")
and i.child() = i1 and i1.child() = i2 and i2.child() = i3 and i3.child() = i4 and i4.child() = i5 and i5.child() = i6 and i6.child() = i7 and i7.child() = i8 and i8.child() = i9 and i9.child() = i10 and i10.child() = i11
and inv.getTarget().hasName("push_back")
and inv.getLocation().toString().matches("%ScriptParser.cpp%329%")
and (inv = i or inv = i1 or inv = i2 or inv = i3 or inv = i4 or inv = i5 or inv = i6 or inv = i7 or inv = i8 or inv = i9 or inv = i10 or inv = i11)
and i.getLocation().toString().matches("%Driver.cpp%1782%")
select i, i1, i2, i3, i4, i5, i6, i7, i8, i9, i10, i11, inv
