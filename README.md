<img width="1440" height="510" alt="Surface Pro 8 - 6" src="https://img1.daumcdn.net/thumb/R1280x0/?scode=mtistory2&fname=https%3A%2F%2Fblog.kakaocdn.net%2Fdna%2Fc4KmOw%2FdJMcahQlSig%2FAAAAAAAAAAAAAAAAAAAAAB6GmcWLyturEVBMAtQao0FL-DrJPDBiB32zBD7FuaUG%2Fimg.png%3Fcredential%3DyqXZFxpELC7KVnFOS48ylbz2pIh7yKj8%26expires%3D1764514799%26allow_ip%3D%26allow_referer%3D%26signature%3DVQDDzCGWy3ts8t34OSjiwgvDKts%253D" />


# 프로젝트 소개

> 매일 새로운 주제와 함께 하루 한 장씩 찰칵 **오늘 한 장 📷**
<br>매일 한 장씩 쌓아가다보면 어느새 잘 찍은 사진이 가득한 나만의 기록이 만들어질거에요


<!-- TODO 기획 의도나 앱 개발 목적 추가? -->

<br>

# 개발 기간

**🗓️ 2025.10.29 ~ 2025.11.20**

<br>

# 기술 스택
- **언어**: Dart
- **프레임워크**:Flutter
- **상태관리**: Provider
- **DI**: Get_it
- **라우팅**: Go_Router
- **이벤트처리**: EventBus
- **백엔드/DB**: Supabase
- **Auth**:google_sign_in
- **Networkd**:Dio
- **알림**:Firebase Cloud Messaging(FCM)
- **로컬알림**:flutter_local_notifications
- **로컬저장소**:shared_preferences
- **이미지처리**: image_picker
- **권한관리**: permission_handler
- **유틸리티**: lottie, intl, fluttertoast

<br>

# 아키텍처

### 시스템 구조도
<img width="1531" height="1042" alt="Frame 120" src="https://img1.daumcdn.net/thumb/R1280x0/?scode=mtistory2&fname=https%3A%2F%2Fblog.kakaocdn.net%2Fdna%2FbXuPly%2FdJMcafSxmoB%2FAAAAAAAAAAAAAAAAAAAAAKJYA4zx8_pwy8ys8RSVj7pGIgZt_2AUcMCqI6ITAzzr%2Fimg.png%3Fcredential%3DyqXZFxpELC7KVnFOS48ylbz2pIh7yKj8%26expires%3D1764514799%26allow_ip%3D%26allow_referer%3D%26signature%3DYK1j7jOmJZP8DRc8%252F0sOb6FW0aM%253D" />

- Supabase를 중심으로 백엔드 구성
    - Auth로 소셜 로그인을 사용하며 구글 로그인 지원
    - 기본적으로 로컬 알림과 FCM 사용
    - UI bakery를 활용한 관리자 페이지 생성완료
  


<br>

# 주요 기능

| 섹션 | 주요 기능 |
|---|---|
| 온보딩 | • 앱 소개 |
| 인증 | • 소셜 로그인 : 구글 |
| 홈 | • 모든 사용자의 게시물 목록 제공 <br>• -날짜를 선택하여 선택한 날짜의 게시물 확인 |
| 게시물 상세 | • 게시물에 대한 좋아요 기능<br>• 댓글 작성<br>• 신고하기 버튼을 통한 게시물 신고<br>• 수정하기 버튼을 통한 게시물 이미지 수정<br>• 삭제하기 버튼을 통한 게시물 삭제 |
| 친구 | • 친구 / 요청 / 차단 목록 조회<br>• 친구 요청 수락으로 친구 맺기 혹은 거절<br>• 친구 삭제 버튼으로 친구 삭제 <br>• 친구 피드 방문하여 친구가 올린 게시물 확인 가능<br>• 차단을 해제 할 수 있음|
| 피드 | • 게시물 모아보기 기능 제공<br>• 타인 피드에서는 차단 / 차단해제, 친구요청 / 요청 취소 가능<br>• 게시물 이미지를 눌러 게시물 상세보기로 이동 |
| 설정 | • 닉네임 변경<br>• 문의 메일 보내기를 통해 이메일 전송<br>• 회원탈퇴를 통하 계정 삭제<br>• 알림 설정을 통한 알림 on/off |

<br>


<br>

## 시연 영상
<p align="center">
  <a href="[https://www.youtube.com/watch?v=mC706rSxEHk](https://youtu.be/WIKUL1WoLgc)">
    <img src="https://img1.daumcdn.net/thumb/R1280x0/?scode=mtistory2&fname=https%3A%2F%2Fblog.kakaocdn.net%2Fdna%2FDToMN%2FdJMcaf54wB5%2FAAAAAAAAAAAAAAAAAAAAAAofEkLwOQjzDiJbRy41p4ATSdanlHL9azYn5urFB9oC%2Fimg.jpg%3Fcredential%3DyqXZFxpELC7KVnFOS48ylbz2pIh7yKj8%26expires%3D1764514799%26allow_ip%3D%26allow_referer%3D%26signature%3Ds4yg6mTbDBXjtfhWdv%252B2N%252Fazmp4%253D" alt="[시연 영상](https://youtu.be/WIKUL1WoLgc)" width="800">
  </a>
</p>

<br>

# 팀원 소개
| 팀장 | 팀원 | 팀원 |
|:----:|:----:|:----:|
|<img width=150 src="https://img1.daumcdn.net/thumb/R1280x0/?scode=mtistory2&fname=https%3A%2F%2Fblog.kakaocdn.net%2Fdna%2Fsylgr%2FdJMcaawVsIF%2FAAAAAAAAAAAAAAAAAAAAAO5a0s1mzrud3TBB-q69RMokzVMZ2lCC1Aszecq4zXQG%2Fimg.png%3Fcredential%3DyqXZFxpELC7KVnFOS48ylbz2pIh7yKj8%26expires%3D1764514799%26allow_ip%3D%26allow_referer%3D%26signature%3D0zhugJdLVqKLSlThgjHQCRZOwYs%253D"/>|<img width=150 src="https://img1.daumcdn.net/thumb/R1280x0/?scode=mtistory2&fname=https%3A%2F%2Fblog.kakaocdn.net%2Fdna%2FbpYHyb%2FdJMcadAmB5Z%2FAAAAAAAAAAAAAAAAAAAAAPM5-Q4t3_5_sJkudbrJ97fa7Vh3GPvWWDH0qerv_wKX%2Fimg.png%3Fcredential%3DyqXZFxpELC7KVnFOS48ylbz2pIh7yKj8%26expires%3D1764514799%26allow_ip%3D%26allow_referer%3D%26signature%3Da9CIQRE1qtViUl%252FVji3h1IQGq9Y%253D"/>|<img width=150 src="https://img1.daumcdn.net/thumb/R1280x0/?scode=mtistory2&fname=https%3A%2F%2Fblog.kakaocdn.net%2Fdna%2FdWCoyD%2FdJMcaawVsIG%2FAAAAAAAAAAAAAAAAAAAAAMz4qeFcI_E_1PI5AbK2nKZBEYafEF4ZwSJ7cBORZ56W%2Fimg.png%3Fcredential%3DyqXZFxpELC7KVnFOS48ylbz2pIh7yKj8%26expires%3D1764514799%26allow_ip%3D%26allow_referer%3D%26signature%3DW9Gkf1AYtiX%252Bp8SmFNP7fSGCUaE%253D">
|[이가은](https://github.com/ggaeunnn)|[이재은](https://github.com/zzeneeee)|[전재민](https://github.com/paul0127-dev)

<br>

## 담당 역할
| 팀원 | 역할 |
|---|---|
| 이가은 | •  git 생성 및 관리<br>• 개발환경 구축 및 파일 생성<br>• Supabase Data table 생성<br>• 홈 UI 및 기능 구현<br>• 상세보기 UI 및 기능 구현<br>• 게시물 작성/수정/신고 UI 및 기능 구현<br>• 좋아요, 댓글 UI 및 기능 구현<br>• UI 베이커리 활용 관리자 페이지 생성<br>• 요구사항 정의서 마무리 |
| 이재은 | •  와이어프레임 생성<br>• 로고 및 전체 UI 디자인<br>• 피드 UI 및 기능 구현<br>• 친구 UI 및 기능 구현<br>• 설정 UI 및 기능 구현<br>• 알림리스트 UI 및 기능 구현<br>• 차단 UI 및 기능 구현<br>• 하단 네비게이션 구현<br>• 스플래시 디자인 및 구현<br>• 카메라/앨범 권한 설정<br>• 구글 클라우드 관리<br>• 전체 UI 통일 작업<br>• 시연 영상 및 발표 자료<br>• 화면정의서 작성 |
| 전재민 | •  피드, 홈 1차 UI 구현<br>• 소셜 로그인 기능 구현<br>• 서버 트리거 및 함수 작업<br>• FCM 푸시 알림 기능 구현<br>• 로컬 푸시 알림 기능 구현<br>• 알림 권한 설정<br>• 온보딩 기능 구현<br>• 푸시알람 라우팅 구현<br>• Auth 뷰모델 구현<br>• API 명세서 작성 |

### 공동작업
- 기획 및 MVP 정의, 기능정의 및 기능명세 작성, 데이터 정의, DB 및 ERD 설계, IA 작성, 플로우 차트 작성
