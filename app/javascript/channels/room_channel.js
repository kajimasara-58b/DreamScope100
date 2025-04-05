import consumer from "./consumer"

const chatChannel = consumer.subscriptions.create("RoomChannel", {
  connected() {
    // Called when the subscription is ready for use on the server
  },

  disconnected() {
    // Called when the subscription has been terminated by the server
  },

  received(data) {
    // Called when there's incoming data on the websocket for this channel
  },

  received(data) {
    if (data.tweet) {
      const tweetsDiv = document.getElementById('tweets');
      tweetsDiv.insertAdjacentHTML('beforeend', data.tweet);
    } else if (data.message) {
      alert(data.message); // エラーメッセージを表示
    }
  },
  speak: function(message) {
    return this.perform('speak', {
      message: message
    });
  }
});

$(document).on('click', '#send-message', function(event) {
  const messageInput = $('[data-behavior~=room_speaker]');
  const message = messageInput.val();
  if (message.trim() !== '') {
    chatChannel.speak(message);
    messageInput.val('');
  }
  return event.preventDefault();
});