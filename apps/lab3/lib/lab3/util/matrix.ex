defmodule Lab3.Util.Matrix do
  @enforce_keys [:rows, :n, :m]
  defstruct [:rows, :n, :m]

  # N rows, M columns
  def new(n, m) do
    %__MODULE__{
      n: n,
      m: m,
      rows:
        for _ <- 1..n do
          for _ <- 1..m do
            0
          end
        end
    }
  end

  def elem(matrix, row, col) do
    matrix.rows
    |> Enum.at(row)
    |> Enum.at(col)
  end

  def set_col(matrix = %__MODULE__{rows: rows}, col, fun) do
    %__MODULE__{
      matrix
      | rows:
          rows
          |> Enum.with_index()
          |> Enum.map(fn {row, row_i} -> List.replace_at(row, col, fun.(row_i)) end)
    }
  end

  def map(matrix = %__MODULE__{rows: _, n: n, m: m}, fun) do
    Enum.reduce(1..(m - 1), matrix, fn j, j_acc ->
      Enum.reduce(0..(n - 2), j_acc, fn i, i_acc ->
        set(i_acc, i, j, fun.(i_acc, i, j))
      end)
    end)
  end

  defp set(matrix, row, col, value) do
    %__MODULE__{
      matrix
      | rows:
          List.replace_at(
            matrix.rows,
            row,
            List.replace_at(Enum.at(matrix.rows, row), col, value)
          )
    }
  end
end
