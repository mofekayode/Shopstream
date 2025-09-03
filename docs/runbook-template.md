# Runbook: [Service/Issue Name]

**Last Updated:** [Date]
**Owner:** [Team Name]
**Severity:** [P1/P2/P3/P4]

## Quick Actions

1. **Check service health**: `kubectl get pods -n shopstream`
2. **View logs**: `kubectl logs -f deployment/[service-name] -n shopstream`
3. **Rollback**: `kubectl rollout undo deployment/[service-name] -n shopstream`

## Symptoms

- [ ] Service returns 5xx errors
- [ ] Response time > 1s p95
- [ ] CPU/Memory usage > 80%
- [ ] Error rate > 1%
- [ ] Other: _____________

## Diagnosis Steps

1. **Check metrics dashboard**
   - CloudWatch: [Dashboard Link]
   - Key metrics: Response time, error rate, throughput

2. **Check recent deployments**
   ```bash
   kubectl rollout history deployment/[service-name]
   ```

3. **Check dependencies**
   - Database connection
   - External service health
   - Network connectivity

## Resolution Steps

### Scenario 1: High CPU/Memory
1. Check for memory leaks in logs
2. Scale horizontally: `kubectl scale deployment/[service] --replicas=3`
3. If persists, investigate code changes

### Scenario 2: Database Connection Issues
1. Check RDS metrics in CloudWatch
2. Verify connection pool settings
3. Check for long-running queries

### Scenario 3: External Service Failure
1. Check service status page
2. Enable circuit breaker
3. Switch to fallback/cache

## Rollback Procedure

```bash
# Get rollout history
kubectl rollout history deployment/[service-name]

# Rollback to previous version
kubectl rollout undo deployment/[service-name]

# Verify rollback
kubectl rollout status deployment/[service-name]
```

## Escalation

1. **L1 (0-15 min)**: On-call engineer
2. **L2 (15-30 min)**: Team lead
3. **L3 (30+ min)**: Platform team
4. **L4 (1hr+)**: Engineering manager

## Post-Incident

- [ ] Create incident report
- [ ] Update runbook with findings
- [ ] Schedule post-mortem
- [ ] Create follow-up tickets

## Related Documentation

- [Architecture Diagram](../diagrams/)
- [Service Documentation](../services/)
- [Alert Configuration](../monitoring/)
- [Previous Incidents](../incidents/)