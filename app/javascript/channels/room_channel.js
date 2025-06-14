import consumer from "./consumer";

consumer.subscriptions.create("RoomChannel", {
  connected() {
    console.log("Connected to RoomChannel");
  },

  disconnected() {
    console.log("Disconnected from RoomChannel");
  },

  received(data) {
    console.log("Received data:", JSON.stringify(data, null, 2));

    const flashContainer = document.getElementById("flash");
    const tweetsContainer = document.getElementById("tweets");

    if (data.error && data.flash) {
      if (flashContainer) {
        flashContainer.innerHTML = data.flash.alert;
        console.log("Flash message set:", data.flash.alert);
      }
      return;
    }

    if (data.tweet && data.tweet_id && data.user_id && data.date && tweetsContainer) {
      const messagesContainer = document.getElementById("messages");
      if (!messagesContainer) {
        console.error("messagesContainer not found. TweetsContainer:", tweetsContainer);
        return;
      }

      // currentUserIdを毎回検証
      const currentUserId = document.querySelector('body')?.dataset.currentUserId?.toString();
      if (!currentUserId) {
        console.error("currentUserId is undefined! Check body[data-current-user-id]");
        return;
      }
      console.log("Current User ID:", currentUserId, "Received User ID:", data.user_id);

      // 非同期でDOM操作
      setTimeout(() => {
        // 日付のセパレーター挿入
        const lastDateElement = messagesContainer.querySelector('[data-date]:last-of-type');
        const newDate = data.date;
        const lastDate = lastDateElement ? lastDateElement.dataset.date : null;

        if (!lastDate || lastDate !== newDate) {
          const dateElement = document.createElement("div");
          dateElement.className = "text-center text-gray-500 text-sm my-4";
          dateElement.dataset.date = newDate;
          dateElement.textContent = new Date(newDate).toLocaleDateString('ja-JP', {
            year: 'numeric',
            month: '2-digit',
            day: '2-digit'
          });
          messagesContainer.appendChild(dateElement);
          console.log("Added date separator:", newDate);
        }

        // HTMLを挿入前に再評価
        let tweetHtml = data.tweet;
        const tempDiv = document.createElement('div');
        tempDiv.innerHTML = tweetHtml;

        const tweetElement = tempDiv.firstElementChild;
        if (tweetElement) {
          const isCurrentUser = data.user_id === currentUserId;
          tweetElement.classList.remove('justify-end', 'justify-start');
          tweetElement.classList.add(isCurrentUser ? 'justify-end' : 'justify-start');

          const flexCol = tweetElement.querySelector('.flex-col');
          if (flexCol) {
            flexCol.classList.remove('items-end', 'items-start');
            flexCol.classList.add(isCurrentUser ? 'items-end' : 'items-start');

            const messageBubble = flexCol.querySelector('.p-3.rounded-lg.max-w-xs.shadow');
            if (messageBubble) {
              messageBubble.classList.remove('bg-green-200', 'bg-white');
              messageBubble.classList.add(isCurrentUser ? 'bg-green-200' : 'bg-white');
            }
          }

          // メッセージを挿入
          messagesContainer.appendChild(tweetElement);
          console.log("Inserted tweet with ID:", data.tweet_id);

          // 入力欄を空にする
          if (isCurrentUser) {
            const speaker = document.querySelector('[data-behavior~=room_speaker]');
            if (speaker) speaker.value = "";
          }

          // スクロール
          scrollToBottom();
        }
      }, 0);
    } else {
      console.error("Invalid broadcast data:", data);
    }
  }
});

// 共通関数
function scrollToBottom() {
  const tweetsContainer = document.getElementById('tweets');
  if (tweetsContainer) {
    tweetsContainer.scrollTop = tweetsContainer.scrollHeight;
  }
}

// 日付変更チェック
function checkDateChange() {
  const messagesContainer = document.getElementById("messages");
  if (!messagesContainer) return;

  const now = new Date();
  const currentDate = now.toLocaleDateString('ja-JP', {
    year: 'numeric',
    month: '2-digit',
    day: '2-digit'
  });
  const lastDateElement = messagesContainer.querySelector('[data-date]:last-of-type');
  const lastDate = lastDateElement ? lastDateElement.dataset.date : null;

  if (!lastDate || lastDate !== now.toISOString().split('T')[0]) {
    const dateElement = document.createElement("div");
    dateElement.className = "text-center text-gray-500 text-sm my-4";
    dateElement.dataset.date = now.toISOString().split('T')[0];
    dateElement.textContent = currentDate;
    messagesContainer.appendChild(dateElement);
    console.log("Added new date separator due to date change:", currentDate);
    scrollToBottom();
  }
}

// 1分ごとに日付変更をチェック
setInterval(checkDateChange, 60000);

// ページ読み込み時にもチェック
document.addEventListener('DOMContentLoaded', checkDateChange);
document.addEventListener('turbo:load', () => {
  const currentUserId = document.querySelector('body')?.dataset.currentUserId?.toString();
  console.log("turbo:load - Current User ID:", currentUserId);
  if (!currentUserId) {
    console.error("turbo:load - currentUserId is missing!");
  }
  setTimeout(scrollToBottom, 100);
  checkDateChange();
});