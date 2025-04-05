import consumer from "./consumer"

const chatChannel = consumer.subscriptions.create("RoomChannel", {
  connected() {
    console.log("Connected to RoomChannel");
  },

  disconnected() {
    console.log("Disconnected from RoomChannel");
  },

  received(data) {
    console.log("Received data:", data);
    if (data.tweet && data.tweet_id) {
      const tweetsDiv = document.querySelector(`[data-tweet-id="${data.tweet_id}"]`);
      if (!existingTweet) {
        // tweet_id をデータ属性として追加
        const tweetElement = `<div data-tweet-id="${data.tweet_id}">${data.tweet}</div>`;
        tweetsDiv.insertAdjacentHTML('beforeend', tweetElement);
        const tweetsContainer = document.getElementById('tweets');
        tweetsContainer.scrollTop = tweetsContainer.scrollHeight;
      } else {
        console.error("Tweets div not found");
      }
    } else if (data.message) {
      alert(data.message);
    }
  },

  speak(message) {
    return this.perform('speak', { message: message });
  }
});

console.log("Setting up chat event listeners"); // デバッグ用

const sendButton = document.getElementById('send-message');
const messageInput = document.querySelector('[data-behavior~=room_speaker]');

if (sendButton && messageInput) {
  console.log("Send button and message input found"); // デバッグ用
  sendButton.addEventListener('click', (event) => {
    console.log("Send button clicked");
    const message = messageInput.value;
    console.log("Message:", message);
    if (message.trim() !== '') {
      console.log("Sending message via chatChannel");
      chatChannel.speak(message);
      messageInput.value = '';
    }
    event.preventDefault();
  });
} else {
  console.error("Send button or message input not found");
  // 要素が見つからない場合、DOM の読み込みを待って再試行
  if (document.readyState === 'loading') {
    document.addEventListener('DOMContentLoaded', () => {
      console.log("Retrying setup after DOMContentLoaded");
      const sendButtonRetry = document.getElementById('send-message');
      const messageInputRetry = document.querySelector('[data-behavior~=room_speaker]');
      if (sendButtonRetry && messageInputRetry) {
        console.log("Send button and message input found on retry");
        sendButtonRetry.addEventListener('click', (event) => {
          console.log("Send button clicked");
          const message = messageInputRetry.value;
          console.log("Message:", message);
          if (message.trim() !== '') {
            console.log("Sending message via chatChannel");
            chatChannel.speak(message);
            messageInputRetry.value = '';
          }
          event.preventDefault();
        });
      } else {
        console.error("Send button or message input still not found after DOMContentLoaded");
      }
    });
  } else {
    console.error("DOM already loaded, but elements not found");
  }
}

// 初回読み込み時に実行
setupChat();

// Turbo によるページ遷移後に再実行
document.addEventListener('turbo:load', setupChat);