# TODO — Remaining

## 1. Fix Docker build

**Error in CI (`Xseed Deploy`):**
```
RUN cat .env  →  cat: .env: No such file or directory
```

`docker/prod/Dockerfile` line 207 expects a `.env` file in the build context.
The file does not exist (gitignored).

**Options:**
- Create `.env.ci` with placeholder values and `COPY` it into the image
- Remove `RUN cat .env` — appears to be a debug/verification step
- Generate `.env` at container startup instead of at build time

---

## 2. First build + push to ECR

Trigger `Xseed Deploy` workflow → Terraform (`kreuzwerker/docker`) builds and pushes:

```
356225522685.dkr.ecr.us-east-1.amazonaws.com/solidtime-production:latest
```

---

## 3. Diagnose ECS services

Once image is in ECR, verify all 4 services reach RUNNING:

| Service | Expected | Notes |
|---------|----------|-------|
| `solidtime-production-http` | 1 task RUNNING | Port 8000, ALB health `/up` → 200 |
| `solidtime-production-worker` | 1 task RUNNING | Queue worker |
| `solidtime-production-scheduler` | 1 task RUNNING | Cron (Supercronic) |
| `solidtime-production-gotenberg` | 1 task RUNNING | Internal, `gotenberg.solidtime.local:3000` |

**Verify:**
- DB migrations ran (`AUTO_DB_MIGRATE=true`)
- `APP_KEY` loaded from Secrets Manager
- Gotenberg reachable from http service
- ALB health check: `curl http://solidtime-production-1484373242.us-east-1.elb.amazonaws.com/up`

**Diagnosis commands:**
```bash
aws ecs describe-services --cluster solidtime-production --services solidtime-production-http solidtime-production-worker solidtime-production-scheduler solidtime-production-gotenberg --profile xseed
aws logs tail /ecs/solidtime-production-http --profile xseed
```

---

## 4. Phase 6 — ACM + HTTPS + DNS

- ACM certificate for `track.xseed.com.uy` (email validation)
- CNAME `track` → `solidtime-production-1484373242.us-east-1.elb.amazonaws.com` in UY DNS provider
- HTTPS listener (port 443) on ALB with ACM cert
- HTTP listener (port 80) → redirect to HTTPS
- Update task definitions:
  - `APP_URL` = `https://track.xseed.com.uy`
  - `APP_FORCE_HTTPS` = `true`
- Redeploy ECS services

---

## 5. Scale to zero (post-validation)

After confirming everything works:
```bash
aws ecs update-service --cluster solidtime-production --service solidtime-production-http --desired-count 0
aws ecs update-service --cluster solidtime-production --service solidtime-production-worker --desired-count 0
aws ecs update-service --cluster solidtime-production --service solidtime-production-scheduler --desired-count 0
aws ecs update-service --cluster solidtime-production --service solidtime-production-gotenberg --desired-count 0
```

---

## Current infrastructure

| Resource | Value |
|----------|-------|
| ALB DNS | `solidtime-production-1484373242.us-east-1.elb.amazonaws.com` |
| ECR | `356225522685.dkr.ecr.us-east-1.amazonaws.com/solidtime-production` |
| RDS | `solidtime-production.cwjy6w6oivbs.us-east-1.rds.amazonaws.com:5432` |
| S3 | `solidtime-production-pwwsahud` |
| VPC | `vpc-0c7f2362584f6981d` |
| ECS Cluster | `solidtime-production` |
| Secrets Manager DB | `solidtime-production-db-ppthwz` |
| Secrets Manager App | `solidtime-production-app-9qgYgL` |
