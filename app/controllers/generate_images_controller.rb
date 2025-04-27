class GenerateImagesController < ApplicationController
  def create
    # ここに画像を作るロジック（仮にbase64で生成されるとする）

    # 仮の画像データ
    image_data = "data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAA..."

    render json: { image_data: image_data }
  end
end
