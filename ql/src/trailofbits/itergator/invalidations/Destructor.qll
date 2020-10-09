private import trailofbits.itergator.iterators
private import cpp

import trailofbits.itergator.invalidations

class PotentialInvalidationDestructor extends PotentialInvalidation {
    PotentialInvalidationDestructor() {
        this instanceof MemberFunction and this.getName().matches("~%")
    }

    override predicate invalidates(Iterated i) {
        i.getType().refersTo(this.getParentScope())
    }
}
