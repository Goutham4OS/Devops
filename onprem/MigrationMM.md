```
                     APPLICATION MIGRATION TO AZURE
                                 │
 ─────────────────────────────────┼─────────────────────────────────
                                 │
                         1. WHY MIGRATE?
                                 │
            ┌───────────────┬───────────────┬───────────────┐
            │               │               │               │
         Scalability     High Availability   Cost Model     Innovation
         Elastic scale    Multi-region HA     OpEx vs CapEx  AI, PaaS, DevOps

                                 │
 ─────────────────────────────────┼─────────────────────────────────
                                 │
                      2. ASSESSMENT PHASE
                                 │
      ┌───────────────┬───────────────┬───────────────┬───────────────┐
      │               │               │               │               │
   App Inventory   Dependencies     SLA Needs     Compliance      Tech Debt
   Discovery        Mapping          RTO/RPO        Regulations     Legacy stack

                                 │
 ─────────────────────────────────┼─────────────────────────────────
                                 │
                      3. MIGRATION STRATEGIES (7Rs)
                                 │
   ┌────────┬────────┬──────────┬─────────┬─────────┬────────┬────────┐
   │Rehost  │Replatf.│Refactor  │Rebuild  │Replace  │Retain  │Retire  │
   │Lift&Shift PaaS   Cloud-native Rewrite SaaS     Hybrid   Decom.  │

                                 │
 ─────────────────────────────────┼─────────────────────────────────
                                 │
                      4. ARCHITECTURE DECISIONS
                                 │
      ┌───────────────┬───────────────┬───────────────┬───────────────┐
      │               │               │               │
   Compute         Database        Networking       Storage
   VM / AppSvc     SQL MI/Cosmos   VNet, VPN, ER    Blob, Files

                                 │
 ─────────────────────────────────┼─────────────────────────────────
                                 │
                      5. AVAILABILITY DESIGN
                                 │
      ┌───────────────┬───────────────┬───────────────┐
      │               │               │
   Single Region   Multi-Zone     Multi-Region
   Basic SLA       Zone HA        Active-Active DR

                                 │
 ─────────────────────────────────┼─────────────────────────────────
                                 │
                      6. MIGRATION EXECUTION
                                 │
      ┌───────────────┬───────────────┬───────────────┬───────────────┐
      │               │               │               │
   Landing Zone   Security Setup  Data Migration   Cutover Plan
   Governance     IAM, Policies   DB/Storage       Testing

  ┌───────────────┬───────────────┬────────────                                │
 ─────────────────────────────────┼─────────────────────────────────
```
   Monitoring      Optimization     Modernization
   Logs, Alerts    Cost, Perf       Replatform later
