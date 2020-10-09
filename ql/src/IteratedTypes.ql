import cpp
import trailofbits.itergator.iterators

from Iterated i
select i.getType().stripType().getName().regexpCapture("(.*?)<.*", 1)
