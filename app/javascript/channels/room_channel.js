import consumer from "./consumer";

let chatChannel;

function setupChat() {
  const sendButton = document.getElementById("send-message");
  const messageInput = document.querySelector('[data-behavior~=room_speaker]');

  if (!sendButton || !messageInput) {
    console.warn("チャット送信ボタンまたは入力フィールドが見つかりません。");
    return;
  }

  console.log("Setting up chat event listeners");

  // すでにサブスクリプションが存在していれば一度解除
  if (chatChannel) {
    consumer.subscriptions.remove(chatChannel);
  }

  // 新たに購読し直す
  chatChannel = consumer.subscriptions.create("RoomChannel", {
    connected() {
      console.log("Connected to RoomChannel");
    },

    disconnected() {
      console.log("Disconnected from RoomChannel");
    },

    received(data) {
      console.log("Received data:", data);
      if (data.tweet && data.tweet_id) {
        const tweetsContainer = document.getElementById("tweets");
        if (tweetsContainer) {
          const tweetElement = `<div data-tweet-id="${data.tweet_id}">${data.tweet}</div>`;
          tweetsContainer.insertAdjacentHTML("beforeend", tweetElement);
          tweetsContainer.scrollTop = tweetsContainer.scrollHeight;
        }
      } else if (data.message) {
        alert(data.message);
      }
    },

    speak(message) {
      return this.perform("speak", { message: message });
    }
  });

  // クリックイベントを再登録
  sendButton.addEventListener("click", (event) => {
    event.preventDefault();
    const message = messageInput.value;
    if (message.trim() !== "") {
      chatChannel.speak(message);
      messageInput.value = "";
    }
  });
}

// Turbo遷移後にも毎回セットアップする
document.addEventListener("turbo:load", setupChat);

// 初期ロードでもセットアップ
document.addEventListener("DOMContentLoaded", setupChat);
