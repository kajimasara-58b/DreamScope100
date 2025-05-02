Rails.application.config.session_store :cookie_store,
  key: "_dreamscope100_session",
  secure: false,
  httponly: true,
  expire_after: 1.day,
  same_site: :lax
