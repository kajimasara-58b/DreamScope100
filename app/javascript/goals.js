document.addEventListener('turbo:load', () => {
  console.log('JavaScript is loaded');

  document.querySelector('.generate-image-button')?.addEventListener('click', function(event) {
    event.preventDefault();
    console.log('Generate image button clicked');

    fetch('/generate_image', {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'X-CSRF-Token': document.querySelector('meta[name="csrf-token"]').content
      },
      body: JSON.stringify({ goal_id: 1 }) // goal_idは動的に入れたいなら後述
    })
    .then(response => response.json())
    .then(data => {
      console.log('Fetch success:', data);
      if (data.image_url) {
        const imagePreview = document.getElementById('image-preview');
        const previewImage = document.getElementById('preview-image');
        const downloadButton = document.getElementById('download-button');
        
        imagePreview.classList.remove('hidden');
        previewImage.src = data.image_url;
        downloadButton.href = data.image_url;
        downloadButton.download = 'goal_summary_image.png';
      } else {
        alert('画像生成に失敗しました。');
      }
    })
    .catch(error => {
      console.error('Fetch error:', error);
      alert('画像生成に失敗しました');
    });
  });
});
