import cpp

import trailofbits.itergator.iterators
import trailofbits.itergator.dataflow
import trailofbits.itergator.invalidations.STL
import trailofbits.itergator.invalidations.Destructor

class NotStackVariable extends Variable {
    NotStackVariable() {
        not this instanceof StackVariable
    }
}

Variable nodeToVariable(DataFlow::Node node) {
    result = node.asExpr().(VariableAccess).getTarget()
}

predicate falsePositive(Iterator it, Invalidator inv) {
    forex (ControlFlowNode n | n = inv.getASuccessor() |
        n.(BreakStmt).getBreakable().(Loop) = it.getParentScope()
        or n.(ReturnStmt).getEnclosingFunction() = it.getParentScope+()
        or exists (ExitBasicBlock b |
            b = n.getBasicBlock() and b.getEnclosingFunction() = it.getParentScope+()
            and not b.contains(it.getAnAccess())
        )
    )
    or inv = it.getAnAssignedValue()
}

from IteratedFlow f1, InvalidatorFlow f2, InvalidationFlow f3, int significance,
DataFlow::Node source, DataFlow::Node invalidationNode, DataFlow::Node iteratedNode, DataFlow::Node invalidatorNode,
Invalidator inv, Iterated itd, Iterator it, Invalidation invd
// set up variables (iterator, iterated, invalidation, and invalidator)
where itd = iteratedNode.asExpr()
and itd = inv.iterated()
and it = itd.iterator()
and inv = invalidatorNode.asExpr().getEnclosingElement()
and inv.invalidation().getChild(-1) = invalidationNode.asExpr()
and invd = invalidationNode.asExpr().getEnclosingElement()
// make sure the actions can operate on the same values
and (
    // the same value flows to the iterator, the invalidator, and the invalidation
    (f1.hasFlow(source, iteratedNode)
    and f2.hasFlow(source, invalidatorNode)
    and f3.hasFlow(source, invalidationNode)
    and f3.hasFlow(invalidatorNode, invalidationNode)
    and significance = 0)
    // or some access of the iterated variable flows to the invalidation
    or (exists (DataFlow::Node source2 |
        f1.hasFlow(source, iteratedNode)
        and f3.hasFlow(source2, invalidationNode)
        // stack variables should have sequential flow (caught by above)
        and nodeToVariable(source).(NotStackVariable) = nodeToVariable(source2).(NotStackVariable)
        and (
            nodeToVariable(source) instanceof GlobalOrNamespaceVariable and significance = 1
            or not nodeToVariable(source) instanceof GlobalOrNamespaceVariable and significance = 2
        )
    ))
)
and not falsePositive(it, inv)
select it, itd, inv, invd, significance order by significance
