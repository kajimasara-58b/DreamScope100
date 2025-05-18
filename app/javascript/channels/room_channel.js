import consumer from "./consumer";

let chatChannel;

function scrollToBottom() {
  const tweetsContainer = document.getElementById("tweets");
  if (tweetsContainer) {
    tweetsContainer.scrollTop = tweetsContainer.scrollHeight;
  }
}

function setupChat() {
  const sendButton = document.getElementById("send-message");
  const messageInput = document.querySelector('[data-behavior~=room_speaker]');

  if (!sendButton || !messageInput) {
    console.warn("チャット送信ボタンまたは入力フィールドが見つかりません。");
    return;
  }

  console.log("Setting up chat event listeners");

  if (chatChannel) {
    consumer.subscriptions.remove(chatChannel);
    console.log("Previous RoomChannel subscription removed");
  }

  chatChannel = consumer.subscriptions.create("RoomChannel", {
    initialized() {
      console.log("RoomChannel initialized");
    },

    connected() {
      console.log("Connected to RoomChannel");
    },

    disconnected() {
      console.log("Disconnected from RoomChannel");
      alert("チャンネル切断！ページをリロードしてください。");
    },

    received(data) {
      console.log("Received data:", JSON.stringify(data, null, 2));
      const flashContainer = document.getElementById("flash");

      if (data.error && data.flash) {
        console.log("Processing flash data:", data.flash);
        alert(data.error);
        if (!flashContainer) {
          console.error("Flash container not found!");
          return;
        }
        fetch("/flash", {
          method: "POST",
          headers: {
            "Content-Type": "application/json",
            "X-CSRF-Token": document.querySelector('meta[name="csrf-token"]').content
          },
          body: JSON.stringify(data.flash)
        })
        .then(response => {
          console.log("Fetch /flash response:", response.status, response.statusText);
          if (!response.ok) {
            throw new Error(`HTTP error! Status: ${response.status}`);
          }
          return response.text();
        })
        .then(html => {
          console.log("Flash HTML received:", html);
          flashContainer.innerHTML = html;
          scrollToBottom();
        })
        .catch(error => {
          console.error("Flash update error:", error.message);
          alert("フラッシュ更新エラー！ページをリロードしてください。");
        });
        return;
      }

      if (data.tweet && data.tweet_id) {
        const tweetsContainer = document.getElementById("tweets");
        if (tweetsContainer) {
          const tweetElement = `<div data-tweet-id="${data.tweet_id}">${data.tweet}</div>`;
          tweetsContainer.insertAdjacentHTML("beforeend", tweetElement);
          messageInput.value = ""; // 成功時のみクリア
          scrollToBottom();
        }
      } else if (data.message) {
        alert(data.message);
      }
    },

    speak(message) {
      console.log("Sending message:", message);
      return this.perform("speak", { message: message });
    }
  });

  sendButton.removeEventListener("click", handleSendClick);
  sendButton.addEventListener("click", handleSendClick);

  function handleSendClick(event) {
    event.preventDefault();
    console.log("Send button clicked");
    const message = messageInput.value;
    console.log("Message:", message);
    if (message.trim() !== "") {
      chatChannel.speak(message);
    } else {
      alert("メッセージを入力してください");
    }
  }
}

document.addEventListener("turbo:load", setupChat);
document.addEventListener("DOMContentLoaded", setupChat);