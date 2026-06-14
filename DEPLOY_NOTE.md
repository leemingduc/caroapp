# Hướng Dẫn & Ghi Chú Deploy GitHub Pages

Tài liệu này tóm tắt các thiết lập đã thực hiện để deploy game Caro Flutter Web lên GitHub Pages và tự động hóa quy trình deploy qua GitHub Actions.

## 1. Các file đã tạo / chỉnh sửa
- **[NEW]** `.github/workflows/deploy.yml`: File cấu hình workflow GitHub Actions để tự động build Flutter Web (phiên bản Flutter `3.38.9`) và deploy lên GitHub Pages mỗi khi có push lên nhánh `main`.
- **[NEW]** `DEPLOY_NOTE.md`: File hướng dẫn này.

## 2. Các lệnh GitHub đã sử dụng
Chúng tôi đã sử dụng GitHub CLI (`gh`) cho các tác vụ:
1. Kiểm tra trạng thái riêng tư của Repository:
   ```bash
   gh repo view --json isPrivate
   ```
2. Chuyển Repository từ **Private** sang **Public** (Do gói GitHub Free không hỗ trợ GitHub Pages trên repo Private):
   ```bash
   gh repo edit --visibility public --accept-visibility-change-consequences
   ```
3. Kích hoạt tính năng GitHub Pages sử dụng nguồn từ GitHub Actions workflow:
   ```bash
   gh api -X POST repos/leemingduc/caroapp/pages -f build_type=workflow
   ```

## 3. Việc bạn cần tự thao tác thủ công (Quan trọng cho Supabase Auth)
Vì ứng dụng có sử dụng **Supabase Auth** để đăng nhập, bạn cần thêm URL của trang web game vào cấu hình của Supabase:
1. Truy cập vào **Supabase Dashboard** của dự án của bạn.
2. Đi tới **Authentication** -> **URL Configuration** -> mục **Redirect URLs**.
3. Bấm **Add URL** và thêm địa chỉ trang web: `https://leemingduc.github.io/caroapp/`
4. Lưu cấu hình.

## 4. Xem link deploy ở đâu?
- **Link chạy game online:** [https://leemingduc.github.io/caroapp/](https://leemingduc.github.io/caroapp/)
- **Theo dõi tiến trình build/deploy:** Truy cập vào tab **Actions** trên repo GitHub của bạn: [https://github.com/leemingduc/caroapp/actions](https://github.com/leemingduc/caroapp/actions)
- Mỗi khi bạn thực hiện push code mới lên nhánh `main`, hệ thống sẽ tự động build lại và cập nhật lên link trên sau khoảng 2-3 phút.
