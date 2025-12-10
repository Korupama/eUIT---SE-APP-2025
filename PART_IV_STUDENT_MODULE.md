# PHẦN IV: CÁC CHỨC NĂNG - MODULE SINH VIÊN

**Dự án:** eUIT Mobile Application
**Ngày:** 10/12/2025
**Phiên bản:** 1.0.0

---

## Tổng quan Module Sinh Viên

Module Sinh Viên là trung tâm của ứng dụng, cung cấp các chức năng quản lý học tập, dịch vụ hành chính, lịch biểu, và thông báo real-time cho sinh viên. 

Kiến trúc module được chia thành 3 lớp:
- **Backend:** API xử lý logic nghiệp vụ
- **Socket Server:** Thông báo real-time 
- **Frontend Mobile:** Giao diện Flutter

---

## I. CÁC CHỨC NĂNG CHÍNH CỦA MODULE SINH VIÊN

### A. QUẢN LÝ HỒ SƠ & THÔNG TIN CÁ NHÂN

#### 1. Xem Thẻ Sinh Viên (Student ID Card)

**Tên API:** GET /api/students/card

**Mô tả chức năng:**
- Hiển thị thông tin cơ bản của sinh viên trên một thẻ đẹp
- Bao gồm: MSSV, họ tên, khóa học, ngành học, ảnh thẻ
- Ảnh thẻ được lưu trên server, frontend xây dựng full URL từ request
- Ảnh được gửi từ endpoint /files/{đường_dẫn}

**Luồng xử lý Backend:**
1. Xác thực người dùng từ JWT token, lấy MSSV
2. Gọi stored function `func_get_student_card_info(mssv)` 
3. Hàm trả về: mssv, ho_ten, khoa_hoc, nganh_hoc, anh_the_url
4. Backend xây dựng full URL: baseUrl + "/files/" + anh_the_url
5. Trả về DTO: StudentCardDto

**Frontend Flow:**
- HomeProvider gọi ApiClient.get('/api/students/card')
- Consumer widget nhận StudentCardDto và hiển thị thẻ
- Ảnh được load từ URL đầy đủ
- Sử dụng widget StudentIdCard với styling theo dark/light theme

**Trạng thái:**
- Loading: Shimmer effect trên widget
- Success: Hiển thị thẻ với tất cả thông tin
- Error: Hiển thị No Content nếu không tìm thấy

---

#### 2. Xem Hồ Sơ Chi Tiết (Student Profile)

**Tên API:** GET /api/auth/profile

**Mô tả chức năng:**
- Hiển thị toàn bộ thông tin hồ sơ chi tiết của sinh viên
- Bao gồm: thông tin cá nhân, gia đình, tài chính, liên hệ
- Dữ liệu lấy từ table `sinh_vien`

**Luồng xử lý Backend:**
1. Xác thực JWT, lấy MSSV từ token
2. Query trực tiếp từ table `sinh_vien` với điều kiện WHERE mssv = {id}
3. Map dữ liệu sang StudentProfileDto
4. Trả về đầy đủ ~40 fields

**Frontend Flow:**
- ProfileScreen gọi AcademicProvider.fetchStudentProfile()
- Hiển thị trong form tĩnh (readonly)
- Có nút Edit để sửa thông tin (future feature)
- Dữ liệu được cache để tránh lần lần gọi API

---

### B. QUẢN LÝ HỌC TẬP

#### 1. Lớp Học Tiếp Theo (Next Class)

**Tên API:** GET /api/students/nextclass

**Mô tả chức năng:**
- Hiển thị thông tin lớp học sắp tới
- Bao gồm: mã lớp, tên môn, giảng viên, thứ, tiết, phòng, ngày, countdown
- Dùng để nhắc nhở sinh viên
- Countdown được tính từ hệ thống

**Luồng xử lý Backend:**
1. Lấy MSSV từ JWT
2. Gọi `func_get_next_class(mssv)` - hàm PostgreSQL
3. Hàm tính toán: ngày hôm nay, thứ, tiết, tiết bắt đầu
4. Trả về class sắp diễn ra nhất
5. Tính countdown_minutes từ thời gian hiện tại

**Frontend Flow:**
- HomeProvider.fetchNextClass() gọi API
- Hiển thị trong NextScheduleCard trên home screen
- Hiển thị countdown real-time (cập nhật hàng phút)
- Nếu không có lớp: hiển thị "Không có lớp hôm nay"
- Có nút "Xem lịch" để đi tới Schedule screen

---

#### 2. Lịch Học (Class Schedule)

**Tên API:** GET /api/student/schedule/classes

**Query Parameters:**
- view_mode: "day" | "week" | "month" | "all"
- filter_by_course: mã môn hoặc tên môn (optional)
- filter_by_lecturer: tên giảng viên (optional)

**Mô tả chức năng:**
- Hiển thị toàn bộ lịch học của sinh viên
- Hỗ trợ lọc theo ngày, tuần, tháng
- Hỗ trợ tìm kiếm theo môn hoặc giảng viên
- Hiển thị chi tiết: mã lớp, tên môn, tín chỉ, giảng viên, thời gian, phòng học

**Luồng xử lý Backend:**
1. Lấy MSSV từ token
2. Gọi `func_get_student_schedule(mssv)` lấy toàn bộ lịch
3. Backend filter client-side:
   - Nếu view_mode = "day": lọc lớp trong ngày hôm nay
   - Nếu "week": lọc lớp trong tuần hiện tại (Monday-Sunday)
   - Nếu "month": lọc lớp trong tháng hiện tại
   - Nếu "all": giữ tất cả từ hôm nay trở đi
4. Kiểm tra filter_by_course và filter_by_lecturer
5. Trả về danh sách ScheduleClassDto

**Helper Function:**
- IsClassOnDate(): kiểm tra xem lớp có diễn ra vào ngày cụ thể không
- Dựa vào: ngay_bat_dau, ngay_ket_thuc, thu (day of week), cach_tuan (interval)

**Frontend Flow:**
- ScheduleProvider.fetchClasses(viewMode, filters)
- Hiển thị trong Schedule tab
- Mặc định view_mode = "week"
- Có toggle để đổi giữa day/week/month/all
- Search box để lọc theo tên môn hoặc giảng viên
- Hiển thị dạng list hoặc calendar grid
- Nếu không có lớp: "Chưa có lịch học"

---

#### 3. Lịch Thi (Exam Schedule)

**Tên API:** GET /api/student/schedule/exams

**Query Parameters:**
- filter_by_semester: mã học kỳ (optional)
- filter_by_group: "GK" | "CK" (midterm/final)

**Mô tả chức năng:**
- Hiển thị lịch thi của sinh viên
- Phân biệt giữa thi giữa kỳ (GK) và thi cuối kỳ (CK)
- Hiển thị: môn, mã lớp, ngày, ca thi, phòng, hình thức thi, tin chỉ

**Luồng xử lý Backend:**
1. Lấy MSSV từ token
2. Nếu filter_by_semester có: gọi `func_get_student_exam_schedule_by_semester(mssv, semester)`
3. Nếu không: gọi `func_get_student_exam_schedule(mssv)`
4. Filter theo filter_by_group (GK hoặc CK) nếu có
5. Trả về danh sách ExamScheduleDto

**Frontend Flow:**
- ScheduleProvider.fetchExams(semester, group)
- Hiển thị trong Exam tab
- Mặc định hiển thị tất cả kỳ thi
- Có filter dropdown cho học kỳ
- Có toggle GK/CK
- Nếu lịch chưa công bố: "Chưa công bố lịch thi"

---

#### 4. Sự Kiện Cá Nhân (Personal Events)

**Tên API:** 
- POST /api/student/schedule/personal (tạo)
- PUT /api/student/schedule/personal/{event_id} (cập nhật)
- DELETE /api/student/schedule/personal/{event_id} (xóa)

**Mô tả chức năng:**
- Sinh viên có thể tạo sự kiện riêng (sinh nhật, cuộc hẹn, ôn tập...)
- Hệ thống cảnh báo nếu có xung đột với lịch học/thi
- Dữ liệu lưu vào table `personal_events`

**Luồng xử lý Backend - POST:**
1. Lấy MSSV từ token
2. Kiểm tra xung đột với lịch học: `CheckClassConflict(mssv, time)`
3. Kiểm tra xung đột với lịch thi: `CheckExamConflict(mssv, time)`
4. Tạo PersonalEvent với mssv, event_name, time, location, description
5. Nếu có xung đột: warning, nhưng vẫn tạo event
6. Trả về PersonalEventCreateResponseDto với thông tin conflict

**Luồng xử lý Backend - PUT:**
1. Tìm event theo event_id và mssv (đảm bảo ownership)
2. Update các field nếu có
3. Kiểm tra xung đột nếu thời gian thay đổi
4. Save và trả về

**Luồng xử lý Backend - DELETE:**
1. Tìm event, kiểm tra ownership
2. Xóa khỏi DB
3. Trả về 200 OK

**Frontend Flow:**
- ScheduleProvider.createPersonalEvent(request)
- Mở dialog/sheet để nhập event details
- Hiển thị warning nếu có xung đột
- Cho phép tạo bất kể có xung đột hay không
- Có nút Edit/Delete trên mỗi event
- Events được hiển thị cùng lịch học/thi

---

#### 5. Quick GPA (GPA Nhanh)

**Tên API:** GET /api/students/quickgpa

**Mô tả chức năng:**
- Hiển thị GPA tích lũy hiện tại
- Hiển thị tổng tín chỉ đã hoàn thành
- Dùng để quick view trên home screen

**Luồng xử lý Backend:**
1. Lấy MSSV từ token
2. Gọi `func_calculate_gpa(mssv)` 
3. Hàm tính GPA từ tất cả khoá học
4. Trả về: gpa (float), so_tin_chi_tich_luy (int)

**Frontend Flow:**
- HomeProvider.fetchQuickGpa()
- Hiển thị trong card trên home screen
- Format: "GPA: 3.45"
- Format: "Tín chỉ: 92/130"
- Có toggle để ẩn/hiện GPA
- Cache 1 giờ

---

#### 6. Danh Sách Điểm (Grades - Transcript)

**Tên API:** 
- GET /api/students/grades (list)
- GET /api/students/grades/details (chi tiết)

**Query Parameters:**
- filter_by_semester: mã học kỳ (optional)

**Mô tả chức năng:**
- Danh sách điểm tất cả môn học theo từng kỳ
- Hiển thị: môn, tín chỉ, điểm tổng kết
- Chi tiết gồm: qua trình, giữa kỳ, thực hành, cuối kỳ, trọng số

**Luồng xử lý Backend - GET /grades:**
1. Lấy MSSV từ token
2. Nếu filter_by_semester: gọi `func_get_student_semester_transcript(mssv, semester)`
3. Nếu không: gọi `func_get_student_full_transcript(mssv)`
4. Map sang GradeDto
5. Trả về GradeListResponseDto

**Luồng xử lý Backend - GET /grades/details:**
1. Lấy MSSV
2. Gọi `func_calculate_gpa(mssv)` để lấy overall GPA
3. Nếu filter_by_semester: gọi `func_get_student_semester_transcript_details(mssv, semester)`
4. Nếu không: gọi `func_get_student_full_transcript_details(mssv)`
5. Group theo học kỳ (hoc_ky)
6. Tính GPA cho từng học kỳ = (Sum(diem * tin_chi)) / Sum(tin_chi)
7. Trả về TranscriptOverviewDto

**Frontend Flow:**
- AcademicProvider.fetchGrades(semester)
- Hiển thị trong Grades screen
- Mặc định hiển thị tất cả kỳ
- Có dropdown chọn học kỳ
- Hiển thị list: môn, tín chỉ, điểm
- Có nút "Chi tiết" để xem breakdown điểm
- Hiển thị GPA tích lũy ở đầu screen
- Hiển thị GPA từng kỳ ở header section

---

#### 7. Điểm Rèn Luyện (Training Scores)

**Tên API:** GET /api/students/training-scores

**Query Parameters:**
- filter_by_semester: mã học kỳ (optional)

**Mô tả chức năng:**
- Hiển thị điểm rèn luyện theo từng học kỳ
- Gồm: tổng điểm, xếp loại (Xuất sắc, Giỏi, Khá, TB khá, TB)
- Tính trạng: Đã xác nhận / Đang chờ xác nhận

**Luồng xử lý Backend:**
1. Lấy MSSV từ token
2. Nếu filter_by_semester: gọi hàm với WHERE filter
3. Nếu không: gọi `func_get_student_training_scores(mssv)`
4. Tính xếp loại dựa trên điểm:
   - 90+: Xuất sắc
   - 80-89: Giỏi
   - 70-79: Khá
   - 60-69: TB khá
   - <60: TB
5. Trả về TrainingScoreListResponseDto

**Frontend Flow:**
- AcademicProvider.fetchTrainingScores(semester)
- Hiển thị trong Training Scores screen
- Hiển thị timeline hoặc table
- Hiển thị xếp loại với color coding
- Có filter học kỳ
- Nếu chưa có: "Đang chờ xác nhận"

---

#### 8. Tiến Độ Học Tập (Progress Tracking)

**Tên API:** GET /api/students/progress

**Mô tả chức năng:**
- Hiển thị tiến độ hoàn thành chương trình đào tạo
- Phân tích theo nhóm môn: Đại cương, Cơ sở, Chuyên ngành, Tốt nghiệp
- Hiển thị: tín chỉ hoàn thành / tín chỉ yêu cầu (%)
- Hiển thị GPA của từng nhóm

**Luồng xử lý Backend:**
1. Lấy MSSV từ token
2. Có 4 nhóm môn: dai_cuong, co_so, chuyen_nganh, tot_nghiep
3. Lặp qua từng nhóm, gọi `func_calculate_progress_tracking(mssv, group)`
4. Hàm trả về: nhom_mon, total_completed_credits, gpa_nhom
5. Tính tổng tín chỉ đã hoàn thành (sum)
6. Lấy nganh_hoc của sinh viên, dùng hàm GetCreditsRequiredForMajor() để lấy yêu cầu
7. Tính completion_percentage = (completed / required) * 100
8. Trả về ProgressTrackingDto

**Frontend Flow:**
- AcademicProvider.fetchProgress()
- Hiển thị trong Progress screen
- Hiển thị progress bar cho từng nhóm
- Hiển thị progress bar tổng quát (tốt nghiệp)
- Hiển thị GPA từng nhóm
- Có section "Còn cần bao nhiêu tín chỉ"

---

#### 9. Kế Hoạch Đào Tạo (Academic Plan)

**Tên API:** GET /api/public/academic-plan (Anonymous)

**Mô tả chức năng:**
- Lấy hình ảnh kế hoạch đào tạo từ website sinh viên
- Dùng web scraping để lấy ảnh từ URL cố định
- Hiển thị trong app dạng fullscreen image

**Luồng xử lý Backend:**
1. Không cần xác thực (AllowAnonymous)
2. Scrape https://student.uit.edu.vn/bieu-do-ke-hoach-dao-tao
3. Tìm tag img với attr src và alt
4. Nếu tìm thấy: trả về dict {alt: src}
5. Nếu không: trả về 404 "Dữ liệu chưa được công bố"
6. Cache image URL để lần sau dùng

**Frontend Flow:**
- AcademicProvider.fetchTrainingProgram()
- Hiển thị trong Plan screen
- Hiển thị image fullscreen với zoom
- Có button download
- Nếu chưa có: "Dữ liệu chưa được công bố"

---

### C. QUẢN LÝ HỌC PHÍ

#### 1. Xem Học Phí (Tuition)

**Tên API:** GET /api/students/tuition

**Query Parameters:**
- filter_by_year: năm học (optional)

**Mô tả chức năng:**
- Hiển thị thông tin học phí theo từng học kỳ
- Bao gồm: tín chỉ, học phí, nợ học kỳ trước, đã đóng, còn lại
- Tổng hợp tất cả học phí, tổng đã đóng, tổng còn lại

**Luồng xử lý Backend:**
1. Lấy MSSV từ token
2. Gọi `func_get_student_tuition(mssv, year_filter)`
3. Hàm trả về list: hoc_ky, so_tin_chi, hoc_phi, no_truoc, da_dong, con_lai
4. Map sang TuitionDto
5. Tính tổng: Sum(hoc_phi), Sum(da_dong), Sum(con_lai)
6. Trả về TotalTuitionDto

**Frontend Flow:**
- AcademicProvider.fetchTuition()
- Hiển thị Tuition screen
- Hiển thị summary card: tổng phí, đã đóng, còn lại
- Hiển thị table chi tiết từng kỳ
- Color code: đỏ nếu còn nợ, xanh nếu đã thanh toán
- Có link đến cổng thanh toán
- Filter theo năm

---

### D. DỊCH VỤ HÀNH CHÍNH

#### 1. Giấy Xác Nhận Sinh Viên (Confirmation Letter)

**Tên API:**
- POST /api/service/confirmation-letter (request)
- GET /api/service/confirmation-letter/history (lịch sử)

**Request Body:**
- purpose: lý do (Xin việc, Du học, Bảo hiểm...)
- language: "vi" | "en"

**Mô tả chức năng:**
- Yêu cầu in giấy xác nhận sinh viên
- Hỗ trợ tiếng Việt và tiếng Anh
- Hệ thống tự phát hành số thứ tự
- Ghi lại lịch sử yêu cầu

**Luồng xử lý Backend - POST:**
1. Lấy MSSV từ token
2. Validate purpose và language
3. Gọi `func_request_confirmation_letter(mssv, purpose, language)`
4. Hàm:
   - Kiểm tra xem sinh viên có bị điều chỉnh, bị đình chỉ không
   - Tạo record mới trong table confirmation_letters
   - Phát hành serial_number tự động
   - Tính ngay_het_han = ngày hôm nay + 90 ngày
5. Trả về: so_thu_tu, ngay_het_han

**Luồng xử lý Backend - GET /history:**
1. Lấy MSSV từ token
2. Gọi `func_get_confirmation_letter_history(mssv)`
3. Trả về danh sách lịch sử: so_thu_tu, purpose, language, status, expiry_date, requested_at

**Frontend Flow:**
- Hiển thị trong Services screen
- Có form nhập purpose + chọn ngôn ngữ
- Submit POST request
- Hiển thị số thứ tự + ngày hết hạn
- Có link "Lịch sử" để xem toàn bộ yêu cầu
- Có button In hoặc Download PDF

---

#### 2. Chứng Chỉ Ngoại Ngữ (Language Certificate)

**Tên API:**
- POST /api/service/language-certificate (submit)
- GET /api/service/language-certificate/history (lịch sử)

**Request (multipart/form-data):**
- certificateType: "TOEFL" | "IELTS" | "TOEIC"...
- score: float (0-990 hoặc 0-120 tùy loại)
- issueDate: date
- expiryDate: date (optional)
- file: PDF | JPG | PNG (max 5MB)

**Mô tả chức năng:**
- Sinh viên nộp chứng chỉ ngoại ngữ
- Hỗ trợ upload file PDF hoặc hình ảnh
- Kiểm tra file type và size
- Lưu lịch sử nộp chứng chỉ

**Luồng xử lý Backend - POST:**
1. Lấy MSSV từ token
2. Validate request data
3. Kiểm tra file: extension (.pdf, .jpg, .jpeg, .png), size <= 5MB
4. Tạo đường dẫn: /uploads/certificates/{mssv}_{timestamp}_{guid}.ext
5. Save file lên disk
6. Gọi `func_submit_language_certificate(mssv, type, score, issue, expiry, path)`
7. Hàm:
   - Validate score range theo loại chứng chỉ
   - Tạo record trong language_certificates
   - Ghi lại created_at, status = "pending"
8. Trả về 200 OK

**Luồng xử lý Backend - GET /history:**
1. Lấy MSSV từ token
2. Gọi `func_get_language_certificate_status(mssv)`
3. Trả về: id, type, score, issue_date, expiry_date, status, file_path, created_at

**Frontend Flow:**
- Hiển thị trong Services screen
- Có form chọn loại chứng chỉ, nhập điểm, chọn ngày
- File picker để chọn file
- Hiển thị preview file nếu là hình ảnh
- Submit và hiển thị success
- Tab "Lịch sử" hiển thị toàn bộ chứng chỉ đã nộp
- Có button download/view file

---

#### 3. Vé Gửi Xe Tháng (Parking Pass)

**Tên API:**
- POST /api/service/parking-pass (đăng ký)
- GET /api/service/parking-pass/history (lịch sử)

**Request Body:**
- vehicleType: "motorbike" | "bicycle"
- licensePlate: biển số (bắt buộc nếu motorbike, optional nếu bicycle)
- registrationMonths: 1-12

**Mô tả chức năng:**
- Sinh viên đăng ký vé gửi xe tháng
- Hỗ trợ xe máy và xe đạp
- Tính toán ngày hết hạn dựa trên số tháng
- Kiểm tra xung đột (không được đăng ký 2 lần)

**Luồng xử lý Backend:**
1. Lấy MSSV từ token
2. Validate: nếu xe máy thì bắt buộc có biển số
3. Gọi `func_register_parking_pass(mssv, licensePlate, vehicleType, registrationMonths)`
4. Hàm:
   - Kiểm tra xem mssv có active pass không
   - Nếu có và chưa hết hạn: return error (Conflict)
   - Tạo record mới trong parking_passes
   - Tính expiry_date = hôm nay + months
   - Ghi lại registered_at
5. Trả về: id, license_plate, vehicle_type, registered_at, expiry_date

**Frontend Flow:**
- Hiển thị trong Services screen
- Có form chọn loại xe, nhập biển số (nếu xe máy)
- Chọn số tháng (1-12)
- Submit POST
- Hiển thị xác nhận với expiry date
- Có QR code để in vé
- Tab "Lịch sử" hiển thị toàn bộ pass đã đăng ký

---

#### 4. Phúc Khảo Điểm (Appeal Grade)

**Tên API:** POST /api/service/appeal

**Request Body:**
- courseId: mã môn học
- reason: lý do phúc khảo
- paymentMethod: "cash" | "online"

**Mô tả chức năng:**
- Sinh viên nộp đơn phúc khảo điểm
- Yêu cầu thanh toán
- Kiểm tra: không được phúc khảo 2 lần cùng 1 môn
- Hỗ trợ 2 cách thanh toán: tiền mặt (pending) hoặc online (completed)

**Luồng xử lý Backend:**
1. Lấy MSSV từ token
2. Validate request
3. Kiểm tra xem MSSV đã nộp phúc khảo cho courseId này chưa
   - Nếu rồi: return BadRequest
4. Xác định paymentStatus:
   - cash: "pending" (cần thanh toán sau)
   - online: "completed" (giả lập thanh toán online thành công)
5. Tạo Appeal record:
   - mssv, courseId, reason, paymentMethod, paymentStatus
   - status = paymentStatus == "completed" ? "pending" : "awaiting_payment"
   - createdAt = hôm nay
6. Trả về AppealResponseDto với message

**Frontend Flow:**
- Hiển thị trong Services > Regrade
- Có dropdown chọn môn học (lấy từ danh sách grades)
- Có text area nhập lý do
- Chọn cách thanh toán
- Submit POST
- Hiển thị xác nhận
- Nếu cash: nhắc nhở đến hạn thanh toán
- Nếu online: redirect đến trang thanh toán (simulated)

---

#### 5. Gia Hạn Học Phí (Tuition Extension)

**Tên API:** POST /api/service/tuition-extension

**Request (multipart/form-data):**
- reason: lý do gia hạn
- requestedMonth: tháng gia hạn
- file: file hỗ trợ (max 10MB)

**Mô tả chức năng:**
- Sinh viên xin gia hạn học phí
- Phải upload file chứng minh (minh chứng khó khăn tài chính)
- Ghi lại thời gian yêu cầu
- Admin sẽ duyệt

**Luồng xử lý Backend:**
1. Lấy MSSV từ token
2. Validate file (PDF, doc, docx; max 10MB)
3. Save file tương tự language certificate
4. Tạo TuitionExtension record:
   - mssv, reason, requested_month, file_path
   - status = "pending"
   - created_at = hôm nay
5. Có thể gửi email thông báo cho admin
6. Trả về 200 OK

**Frontend Flow:**
- Hiển thị trong Services screen
- Có form nhập lý do, chọn tháng gia hạn
- File picker upload tài liệu hỗ trợ
- Submit
- Hiển thị xác nhận "Yêu cầu đang được xử lý"

---

### E. THÔNG TIN & NỘI DUNG

#### 1. Tin Tức & Thông Báo (News)

**Tên API:** GET /news (Anonymous)

**Mô tả chức năng:**
- Hiển thị tin tức mới nhất từ nhà trường
- Lấy từ hàm SQL: `get_latest_bai_viet()`
- Hiển thị: tiêu đề, link, ngày đăng

**Luồng xử lý Backend:**
1. Không cần xác thực
2. Execute: `SELECT * FROM get_latest_bai_viet()`
3. Trả về list: tieu_de, url, ngay_dang
4. Map sang NewsDTO

**Frontend Flow:**
- ContentService.fetchNews()
- Hiển thị trong News screen
- Hiển thị dạng list item
- Mỗi item có: tiêu đề, ngày đăng, nút "Đọc thêm"
- Click item: mở WebView hoặc browser ngoài

---

#### 2. Quy Định & Quy Chế (Regulations)

**Tên API:** GET /api/regulations

**Mô tả chức năng:**
- Hiển thị các quy định, quy chế của nhà trường
- Bao gồm: quy chế học tập, quy chế thi, quy định rèn luyện...
- Hiển thị dạng danh sách hoặc PDF

**Luồng xử lý Backend:**
1. Query từ table hoặc API ngoài
2. Trả về danh sách regulations với: title, url, type

**Frontend Flow:**
- AcademicProvider.fetchRegulations()
- Hiển thị trong Regulations screen
- Có search để tìm quy định
- Click để xem chi tiết (PDF hoặc HTML)

---

### F. THÔNG BÁO REAL-TIME

#### Kiến trúc SignalR

**Socket Server Endpoint:** /notifications

**Luồng kết nối:**
1. Frontend kết nối: HubConnectionBuilder → http://localhost:5000/notifications
2. Đính kèm JWT token qua HttpConnectionOptions
3. Server kiểm tra token, nếu hợp lệ thì chấp nhận
4. Client invoke `Subscribe(mssv)` để đăng ký nhận thông báo

**Cấu trúc Group:**
- Mỗi sinh viên có group: "student_{mssv}"
- Khi backend gửi notification, nó gửi đến group này
- Tất cả thiết bị của sinh viên nhận cùng lúc

---

#### 1. Thông Báo Cập Nhật Điểm

**Event:** ReceiveKetQuaHocTap

**Kích hoạt:** Khi giảng viên hoặc hệ thống cập nhật điểm

**Luồng Backend → Socket:**
1. Backend gọi: POST /api/notify/ket-qua-hoc-tap/{maSinhVien}
2. Payload:
   - MaMonHoc
   - TenMonHoc
   - MaLopHocPhan
   - DiemQuaTrinh, DiemGiuaKy, DiemCuoiKy, DiemTongKet
   - DiemChu (A, B, C...)
   - HocKy, NamHoc

3. Socket Server wrapper payload với:
   - type: "ket_qua_hoc_tap"
   - title: "Cập nhật điểm: {TenMonHoc}"
   - message: "QT: X | GK: Y | CK: Z"
   - timestamp
4. Gửi đến group: `student_{maSinhVien}`

**Luồng Frontend - Mobile:**
1. NotificationService.onKetQuaHocTap stream lắng nghe event
2. Nhận payload, parse dữ liệu
3. Tạo NotificationItem
4. Thêm vào HomeProvider._notifications (top of list)
5. Hiển thị notification overlay hoặc badge
6. User click: navigate tới Grades screen tương ứng

---

#### 2. Thông Báo Báo Bù

**Event:** ReceiveBaoBu

**Kích hoạt:** Giảng viên công bố lịch học bù

**Payload:**
- MaLopHocPhan
- TenMonHoc
- NgayBu (ngày bù)
- TietBatDau, TietKetThuc
- PhongHoc
- GhiChu (optional)

**Frontend:**
1. Hiển thị notification: "Lịch học bù: {TenMonHoc}"
2. Hiển thị chi tiết: ngày, tiết, phòng
3. Badge "1 bù" trên Schedule tab
4. Click: navigate tới lịch học, highlight lớp bù

---

#### 3. Thông Báo Báo Nghỉ

**Event:** ReceiveBaoNghi

**Kích hoạt:** Giảng viên đăng ký nghỉ lớp

**Payload:**
- MaLopHocPhan
- TenMonHoc
- NgayNghi
- LyDo
- GhiChu

**Frontend:**
1. Hiển thị notification: "Nghỉ học: {TenMonHoc}"
2. Hiển thị chi tiết: ngày, lý do
3. Badge "1 nghỉ" trên Schedule
4. Click: navigate tới Schedule

---

#### 4. Thông Báo Điểm Rèn Luyện

**Event:** ReceiveDiemRenLuyen

**Kích hoạt:** Hệ thống công bố điểm rèn luyện

**Payload:**
- HocKy
- NamHoc
- DiemRenLuyen
- XepLoai (Xuất sắc, Giỏi, Khá...)

**Frontend:**
1. Hiển thị notification: "Điểm rèn luyện HK{HocKy}"
2. Hiển thị: điểm + xếp loại
3. Click: navigate tới Training Scores

---

## II. FLOW TỔNG QUAN TỪ BACKEND ĐẾN FRONTEND

### Tình huống: Sinh viên mở app

1. **LoadingScreen** hiển thị khi app khởi động
2. **AuthService.initialize()** kiểm tra token cũ
3. Nếu token hợp lệ: tiến hành prefetch dữ liệu:
   - HomeProvider.prefetch() → fetchQuickGpa(), fetchStudentCard(), fetchNextClass()
   - ScheduleProvider.prefetch() → fetchClasses(week), fetchExams()
   - AcademicProvider.prefetch() → fetchGrades(), fetchTuition(), fetchTrainingScores()
4. Lấy MSSV từ token, kết nối SignalR: connectNotifications(mssv)
5. Chuyển qua **MainScreen** khi prefetch xong
6. HomeProvider._setupNotificationListeners() bắt đầu lắng nghe các event

### Tình huống: Giảng viên cập nhật điểm

1. Giảng viên nhập điểm trong hệ thống (không phải ứng dụng này)
2. Backend trigger event
3. Backend gọi: POST /api/notify/ket-qua-hoc-tap/23520541
4. Socket Server nhận, wrap payload, gửi đến group "student_23520541"
5. Frontend nhận event "ReceiveKetQuaHocTap" qua NotificationService.onKetQuaHocTap
6. HomeProvider tạo NotificationItem, thêm vào list
7. Giao diện update: hiển thị notification overlay
8. Sinh viên click: navigate tới Grades screen
9. AcademicProvider.fetchGrades(forceRefresh: true) để lấy dữ liệu mới

### Tình huống: Sinh viên xem lịch học

1. Mở Schedule tab
2. ScheduleProvider.fetchClasses(viewMode: 'week') gọi API
3. Backend trả về danh sách lớp trong tuần
4. Frontend hiển thị dạng timeline hoặc calendar
5. Có search/filter box
6. Click vào lớp: xem chi tiết (giảng viên, phòng, link Zoom...)
7. Có nút "Thêm sự kiện cá nhân" để tạo reminder

### Tình huống: Sinh viên nộp giấy xác nhận

1. Mở Services tab
2. Click "Giấy xác nhận sinh viên"
3. Chọn lý do + ngôn ngữ
4. Submit POST /api/service/confirmation-letter
5. Backend xử lý, phát hành số thứ tự
6. Frontend hiển thị: số thứ tự + ngày hết hạn
7. Có nút "In" hoặc "Download PDF" (frontend logic)
8. Có tab "Lịch sử" hiển thị toàn bộ yêu cầu trước đó

---

## III. CACHE STRATEGY

**HomeProvider:**
- studentCard: cache persistent (chỉ refresh khi login/logout)
- nextClass: cache 5 phút
- quickGpa: cache 1 giờ
- notifications: cache in-memory, ko clear

**ScheduleProvider:**
- scheduleClasses: cache persistent (semester)
- examSchedules: cache persistent (semester)
- personalEvents: cache in-memory

**AcademicProvider:**
- grades: cache persistent per semester
- tuition: cache 1 giờ
- trainingScores: cache persistent per semester
- progress: cache 1 giờ
- trainingProgram: cache persistent

**Rule:**
- forceRefresh = true: bỏ qua cache, lấy từ API
- Token change: clear toàn bộ cache
- Pull-to-refresh: đặt forceRefresh = true

---

## IV. GIAO DIỆN (UI/UX)

### Home Screen
- Header với tên sinh viên + avatar
- Student ID Card widget (expandable)
- Quick GPA card
- Next Schedule card (countdown)
- Notifications section (mới nhất 1-2 cái)
- Quick Actions grid (customizable)
- Pull-to-refresh

### Schedule Screen
- Tabs: Classes | Exams | Personal
- Classes: view mode toggle (day/week/month/all)
- Search + filter dropdown
- Timeline hoặc calendar view
- Exams: filter semester + GK/CK toggle
- Personal: floating button tạo event

### Grades Screen
- GPA summary card ở đầu
- Semester selector dropdown
- List of grades (môn, tín chỉ, điểm)
- "Chi tiết" button → mở breakdown
- Breakdown: hiển thị điểm QT/GK/TH/CK, trọng số, GPA kỳ

### Services Screen
- Grid layout: 6 service tiles
  1. Giấy xác nhận
  2. Vé gửi xe
  3. Chứng chỉ ngoại ngữ
  4. Phúc khảo
  5. Gia hạn học phí
  6. Giấy giới thiệu (future)
- Mỗi tile: icon + title + subtitle
- Click: navigate tới form/screen tương ứng

### Settings & Profile
- Profile: readonly display của thông tin cá nhân
- Settings: theme toggle, language selector, logout

---

## V. ERROR HANDLING & USER FEEDBACK

**Backend Errors:**
- 401: Token invalid/expired → logout, redirect login
- 403: Forbidden → hiển thị "Bạn không có quyền"
- 404: Not found → "Không tìm thấy dữ liệu"
- 409: Conflict (e.g., duplicate appeal) → "Bạn đã nộp rồi"
- 500: Server error → "Lỗi server, vui lòng thử lại"

**Network Errors:**
- Timeout → retry dialog
- No internet → offline mode (hiển thị cached data)
- Slow network → loading indicator

**Validation Errors:**
- Form validation: red border + error text
- File size exceeded: toast message
- Invalid file type: toast message

---

## VI. HIỆU NĂNG TỐI ƯU

1. **Lazy Loading:**
   - Schedule classes: load on demand
   - Grades: paginate (10 items/page)
   - Notifications: infinite scroll

2. **Image Optimization:**
   - Student avatar: cache locally
   - Resize nếu > 500KB
   - Use webp format nếu có thể

3. **Database Queries:**
   - Use indexes trên mssv, hoc_ky
   - Stored procedures thay vì ORM complex queries
   - Connection pooling

4. **Frontend:**
   - Provider: use Selector để optimize rebuild
   - Shimmer loading thay vì blank screen
   - Local cache với TTL
   - Prefetch dữ liệu phổ biến

---

## KẾT LUẬN

Module Sinh Viên là core của ứng dụng, cung cấp toàn bộ chức năng quản lý học tập, dịch vụ hành chính, và real-time notifications. Kiến trúc 3-tầng (Backend → Socket → Mobile) cho phép:

- Xử lý logic phức tạp ở backend (tính GPA, lọc lịch, kiểm tra xung đột)
- Real-time updates qua SignalR (thông báo điểm, báo bù, báo nghỉ)
- Giao diện người dùng responsive trên mobile (Flutter)

Tất cả dữ liệu được cache thông minh để tối ưu bandwidth và performance. Error handling toàn diện đảm bảo user experience mượt mà ngay cả trong điều kiện mạng kém.

---

**End of Part IV - Student Module**

**Tiếp theo:** Part V sẽ mô tả Module Giảng Viên và các chức năng quản lý lớp học, điểm số.

