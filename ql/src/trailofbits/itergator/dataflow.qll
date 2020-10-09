private import cpp
private import trailofbits.itergator.iterators

import semmle.code.cpp.dataflow.DataFlow

class IteratorFlow extends DataFlow::Configuration {
    IteratorFlow() { this = "IteratorFlow" }

    override predicate isSource(DataFlow::Node source) {
        source.asExpr() instanceof Access
        or exists (source.asParameter())
    }

    override predicate isSink(DataFlow::Node sink) {
        sink.asExpr().(Access).getTarget() instanceof Iterator
    }

    override predicate isBarrier(DataFlow::Node node) {
        node.asExpr().(FunctionCall).getTarget() instanceof CopyConstructor
    }
}

class IteratedFlow extends DataFlow::Configuration {
    IteratedFlow() { this = "IteratedFlow" }

    override predicate isSource(DataFlow::Node source) {
        source.asExpr() instanceof Access
        or exists (source.asParameter())
    }

    override predicate isSink(DataFlow::Node sink) {
        sink.asExpr() instanceof Iterated
    }

    override predicate isBarrier(DataFlow::Node node) {
        node.asExpr().(FunctionCall).getTarget() instanceof CopyConstructor
    }
}

class InvalidationFlow extends DataFlow::Configuration {
    InvalidationFlow() { this = "InvalidationFlow" }

    override predicate isSource(DataFlow::Node source) {
        exists (Access a | a = source.asExpr())
        or exists (source.asParameter())
    }

    override predicate isSink(DataFlow::Node sink) {
        exists (Invalidation i | sink.asExpr() = i.getChild(-1))
    }

    override predicate isBarrier(DataFlow::Node node) {
        node.asExpr().(FunctionCall).getTarget() instanceof CopyConstructor
    }
}

class InvalidatorFlow extends DataFlow::Configuration {
    InvalidatorFlow() { this = "InvalidatorFlow" }

    override predicate isSource(DataFlow::Node source) {
        exists(source)
    }

    override predicate isSink(DataFlow::Node sink) {
        sink.asExpr().getEnclosingElement() instanceof Invalidator
    }

    override predicate isBarrier(DataFlow::Node node) {
        node.asExpr().(FunctionCall).getTarget() instanceof CopyConstructor
    }
}
