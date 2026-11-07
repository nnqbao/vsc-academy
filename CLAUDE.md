# VSC Academy — Claude Code Instructions

## Cổng Convex self-hosted (đọc trước khi chạy compose)

Repo này được clone nhiều lần trên Mac Mini (`VSC-ACADEMY`, `VSC-ACADEMY-hardening`, và các
worktree của agent). Mọi bản dùng chung một `docker-compose.yml` đã commit, nên **giá trị trong git
chỉ giữ được một bộ cổng**. Vì thế cổng và tên compose project là **tham số**, đọc từ
`infra/convex-local/.env` (file này bị `.gitignore`, không lên repo).

Mặc định trong git — tức phần đặt chỗ của bản `VSC-ACADEMY`:

| Biến | Mặc định |
|---|---|
| `ACADEMY_CONVEX_PROJECT` | `vsc-academy-convex` |
| `ACADEMY_CONVEX_INSTANCE` | `vsc-academy-local` |
| `ACADEMY_CONVEX_PORT` | `3320` (backend) |
| `ACADEMY_CONVEX_SITE_PORT` | `3321` (HTTP actions) |
| `ACADEMY_CONVEX_DASHBOARD_PORT` | `6800` |

Bản `VSC-ACADEMY-hardening` có `.env` riêng: `3322` / `3323` / `6807`, project
`vsc-academy-hardening-convex`. Hai bản đã chạy song song được, mỗi bản một volume riêng.

**Nếu bạn làm việc trong một bản clone khác và cần chạy backend riêng**: copy
`infra/convex-local/.env.example` thành `.env`, chọn cổng trống từ `~/ops/docs/convex-ports.md`,
rồi thêm bản của bạn vào bảng trong sổ đó.

`ACADEMY_CONVEX_PROJECT` **phải khác nhau giữa các bản**. Đó là tên compose project, và volume đặt
tên theo nó — hai bản trùng tên là chung một database, ghi đè dữ liệu của nhau.

Kiểm tra một cổng có trống không phải làm **cả hai** bước, vì cổng do dự án đang tắt đặt chỗ sẽ
không hiện trong `lsof`:

```sh
lsof -nP -iTCP -sTCP:LISTEN | grep -E ':(3320|6800)$'
grep -rn '127.0.0.1:3320:' ~/projects ~/ops/infra --include=docker-compose.yml
```

**Tuyệt đối không dùng 3280/3281/6796** — đó là backend của teduenglish đang chạy. Repo này từng
hardcode 3280 ở 7 chỗ; chạy thiếu biến môi trường là CMS ghi thẳng vào database của teduenglish.
Đã sửa 2026-11-07.

### Nguồn cổng duy nhất

`infra/convex-local/.env` là nơi duy nhất khai cổng cho một bản. Những chỗ sau tự đọc từ đó,
đừng hardcode lại:

- `infra/convex-local/docker-compose.yml` — cả `ports:` lẫn các origin
- `scripts/vsc-academy-convex-env.sh`, `scripts/vsc-academy-convex-ensure.sh` — cùng tự suy ra
  đường dẫn repo từ vị trí script, nên mỗi bản quản đúng stack của mình

`cms/lib/convex-db.js`, `seed-convex.mjs`, `upsert-admin.mjs` vẫn có hằng `3320` làm giá trị chót
khi thiếu cả `CONVEX_SELF_HOSTED_URL` lẫn `CONVEX_URL`. Chạy CMS ở bản clone khác thì đi qua
`scripts/vsc-academy-convex-env.sh` để lấy đúng cổng của bản đó.

## Convex thật đang ở Cloud, không phải local

LaunchAgent `ai.vsc.academy.web` chạy với `CONVEX_URL=https://affable-swordfish-496.convex.cloud`.
Bản self-hosted local chỉ là chỗ đặt sẵn / dùng khi phát triển; các giá trị mặc định
`127.0.0.1:<cổng>` chỉ có tác dụng khi biến môi trường bị thiếu.

Chính vì thế việc giữ đúng cổng mới quan trọng: mặc định sai là ghi nhầm database của dự án khác.
