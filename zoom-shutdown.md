## About: Async Shutdown

**Problem** Shutting down hundreds of fibers/threads/processes with interdependent and dynamic dependencies.

**Role** Safety specialist.

**Setting** Firefox developers unaware of the problem. High percentage of deadlocks, livelocks and data loss.

**Mechanism**

- Dynamic shutdown blocker model.
- Resolution of shutdown blockers.
- Error-tracking mechanism.

**Nowadays** Used by all Firefox developers who manipulate data.

**Possible future work** π-calculus definition/type system.
