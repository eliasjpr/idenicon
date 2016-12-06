defmodule Idenicon do

  def main(input) do
    hash_input(input)
    |> pick_color
    |> build_grid
    |> filter_odd_squares
    |> build_pixel_map
    |> draw_image(input)
  end

  def hash_input(input) do
    hex = :crypto.hash(:md5, input) |> :binary.bin_to_list
    %Idenicon.Image{ hex: hex }
  end

  def pick_color( %Idenicon.Image{ hex: [ a, b, c | _tail ] } = image) do
    %Idenicon.Image{ image | color: { a, b, c }}
  end

  def build_grid(%Idenicon.Image{ hex: hex } = image) do
    grid =
      hex
      |> Enum.chunk(3)
      |> Enum.map(&mirror_row/1)
      |> List.flatten
      |> Enum.with_index
    %Idenicon.Image{ image | grid: grid }
  end

  def filter_odd_squares(%Idenicon.Image{ grid: grid } = image ) do
    grid = Enum.filter grid, fn ({x, _index }) ->
      rem(x, 2) == 0
    end
    %Idenicon.Image{ image | grid: grid }
  end

  def build_pixel_map(%Idenicon.Image{ grid: grid } = image) do
    pixel_map = Enum.map grid, fn ({_, index}) ->
       x = rem(index, 5) * 50
       y = div(index, 5) * 50
      {{x, y}, {x + 50, y + 50}}
    end
    %Idenicon.Image{ image | pixel_map: pixel_map }
  end

  def draw_image(%Idenicon.Image{ pixel_map: pixel_map, color: color }, input) do
    image = :egd.create(250, 250)
    fill = :egd.color(color)
    Enum.each pixel_map, fn ({x, y}) ->
      :egd.filledRectangle(image, x, y, fill)
    end
    bin_image = :egd.render(image)
    save_image(bin_image, input )
  end

  def save_image(image, input) do
    File.write("#{input}.png", image)
  end

  def mirror_row([a, b, c]) do
    [a, b, c, b, a]
  end
end
