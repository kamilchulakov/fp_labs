# Лабораторная работа №1
## Вариант
- 4: https://projecteuler.net/problem=4
- 27: https://projecteuler.net/problem=27

## Цель работы
Освоить базовые приёмы и абстракции функционального программирования: функции, поток управления и поток данных, сопоставление с образцом, рекурсия, свёртка, отображение, работа с функциями как с данными, списки.

## 4. Largest Palindrome Product

### Описание проблемы
<p>A palindromic number reads the same both ways. The largest palindrome made from the product of two $2$-digit numbers is $9009 = 91 \times 99$.</p>
<p>Find the largest palindrome made from the product of two $3$-digit numbers.</p>

### Решение через генератор
Генерация пар трёхзначных чисел, которые являются палиндромом.
```elixir
  def largest_palindrome_product_of_3digit_numbers do
    for x <- 999..100, y <- x..100, is_palindrome_product(x, y) do
      x * y
    end
    |> Enum.max()
  end
```

### Решение через бесконечную последовательность
```elixir
  def largest_palindrome_product_of_3digit_numbers do
    range_cycle = Stream.cycle(@min_max_range)
    range_to_x = &(Stream.take(range_cycle, &1 - @min_num))
    map_to_product = &(Stream.map(&1, fn y -> &2 * y end))

    range_cycle
    |> Stream.take(@nums_count)
    |> Stream.flat_map(fn x ->
      range_to_x.(x)
      |> map_to_product.(x)
    end)
    |> Stream.filter(&is_palindrome(&1))
    |> max_product()
  end
```

### Решение через бесконечные последовательности
```elixir
  defp max_product(stream) do
    stream
    |> foldl(nil, fn product, acc ->
      cond do
        acc == nil -> product
        product > acc -> product
        true -> acc
      end
    end)
  end
```

#### Stream.cycle

```elixir
  @spec largest_palindrome_product_of_3digit_numbers :: integer
  def largest_palindrome_product_of_3digit_numbers do
    range_cycle = Stream.cycle(@min_max_range)
    range_to_x = &Stream.take(range_cycle, &1 - @min_num)
    map_to_product = &Stream.map(&1, fn y -> &2 * y end)

    range_cycle
    |> Stream.take(@nums_count)
    |> Stream.flat_map(fn x ->
      range_to_x.(x)
      |> map_to_product.(x)
    end)
    |> Stream.filter(&is_palindrome(&1))
    |> max_product()
  end
```

#### Stream.iterate

```elixir
  def largest_palindrome_product_of_3digit_numbers_iter do
    map_next = &Stream.map(&1..@max_num, fn y -> &1 * y end)
    next_fun = fn {num, _} -> {num+1, map_next.(num+1)} end
    iterate_stream = Stream.iterate({99, []}, next_fun)

    iterate_stream
    |> Stream.take(@nums_count)
    |> Stream.flat_map(fn {_, products} ->
      products
    end)
    |> Stream.filter(&is_palindrome(&1))
    |> max_product()
  end
```

## 27. Quadratic Primes

### Описание проблемы

<p>Euler discovered the remarkable quadratic formula:</p>
<p class="center">$n^2 + n + 41$</p>
<p>It turns out that the formula will produce $40$ primes for the consecutive integer values $0 \le n \le 39$. However, when $n = 40, 40^2 + 40 + 41 = 40(40 + 1) + 41$ is divisible by $41$, and certainly when $n = 41, 41^2 + 41 + 41$ is clearly divisible by $41$.</p>
<p>The incredible formula $n^2 - 79n + 1601$ was discovered, which produces $80$ primes for the consecutive values $0 \le n \le 79$. The product of the coefficients, $-79$ and $1601$, is $-126479$.</p>
<p>Considering quadratics of the form:</p>

$n^2 + an + b$, 
where $|a| &lt; 1000$ and $|b| \le 1000$

<br><br>
where $|n|$ is the modulus/absolute value of $n$<br>e.g. $|11| = 11$ and $|-4| = 4$

<p>Find the product of the coefficients, $a$ and $b$, for the quadratic expression that produces the maximum number of primes for consecutive values of $n$, starting with $n = 0$.</p>

### Решение
Поиск лучших `a` и `b` через генераторы и max_by по `n`.

```elixir
defp find_best do
    limit_a = -1000..999
    limit_b = -1000..1000
    for a <- limit_a, b <- limit_b do
      max_continuous_prime(0, a, b)
    end
    |> Enum.max_by(&comparator(&1), fn -> nil end)
  end
```

## Свёртки

```elixir
  def foldr([head | []], acc, fun), do: fun.(head, acc)
  def foldr([head | tail], acc, fun), do: fun.(head, foldr(tail, acc, fun))
  def foldr(stream, acc, fun), do: foldr(Enum.to_list(stream), acc, fun)

  def foldl([], acc, _fun), do: acc
  def foldl([head | tail], acc, fun), do: foldl(tail, fun.(head, acc), fun)
  def foldl(stream, acc, fun), do: foldl(Enum.to_list(stream), acc, fun)
```

```markdown
##### With input Bigger #####

Name ips average deviation median 99th %
foldl 1.13 K 0.88 ms ±40.09% 0.73 ms 2.18 ms
foldr 0.41 K 2.47 ms ±22.66% 2.32 ms 4.75 ms

Comparison:
foldl 1.13 K
foldr 0.41 K - 2.79x slower +1.59 ms

##### With input Medium #####

Name ips average deviation median 99th %
foldl 13.32 K 75.08 μs ±33.06% 67.34 μs 138.04 μs
foldr 4.00 K 249.85 μs ±28.76% 234.28 μs 561.24 μs

Comparison:
foldl 13.32 K
foldr 4.00 K - 3.33x slower +174.77 μs

##### With input Small #####

Name ips average deviation median 99th %
foldl 90.91 K 11.00 μs ±847.11% 7.27 μs 28.68 μs
foldr 45.82 K 21.83 μs ±89.00% 20.32 μs 33.11 μs

Comparison:
foldl 90.91 K
foldr 45.82 K - 1.98x slower +10.83 μs
```

## Вывод

В ходе работы познакомился с базовыми концепциями функционального программирования на примере Elixir: рекурсия, свёртки,
последовательности, генераторы, попробовал делать бенчи.
