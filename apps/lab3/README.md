# Лабораторная работа №3

## Цель работы
Получить навыки работы с вводом/выводом, потоковой обработкой данных, командной строкой.

## Требования к разработанному ПО
- обязательно должна быть реализована линейная интерполяция (отрезками, [link](https://en.wikipedia.org/wiki/Linear_interpolation));
- настройки алгоритма аппроксимирования и выводимых данных должны задаваться через аргументы командной строки:
    - какие алгоритмы использовать (в том числе два сразу);
    - частота дискретизации результирующих данных;
    - и т.п.;
- входные данные должны задаваться в текстовом формате на подобии ".csv" (к примеру `x;y\n` или `x\ty\n`) и подаваться на стандартный ввод, входные данные должны быть отсортированы по возрастанию x;
- выходные данные должны подаваться на стандартный вывод;
- программа должна работать в потоковом режиме (пример -- `cat | grep 11`), это значит, что при запуске программы она должна ожидать получения данных на стандартный ввод, и, по мере получения достаточного количества данных, должна выводить рассчитанные точки в стандартный вывод;

Приложение должно быть организовано следующим образом:

```text
    +---------------------------+
    | обработка входного потока |
    +---------------------------+
            |
            | поток / список / последовательность точек
            v
    +------------------------+      +------------------------------+
    | алгоритм аппроксимации |<-----| генератор точек, для которых |
    +------------------------+      | необходимо вычислить         |
            |                       | аппроксимированное значение   |
            |                       +------------------------------+
            |
            | поток / список / последовательность рассчитанных точек
            v
    +------------------------+
    | печать выходных данных |
    +------------------------+
```

## Общие требования:
- программа должна быть реализована в функциональном стиле;
- ввод/вывод должен быть отделён от алгоритмов аппроксимации;
- требуется использовать идиоматичный для технологии стиль программирования.

## Общие рекомендации по реализации. 
Не стоит писать большие и страшные автоматы, управляющие поведением приложения в целом. Если у вас:

- Язык с ленью -- используйте лень.
- Языки с параллельным программированием и акторами -- используйте их.
- Язык без всей этой прелести -- используйте генераторы/итераторы/и т.п.

## Особенности реализации
### GenStage
>  GenStage provides a way for us to define a pipeline of work to be carried out by independent steps (or stages) in separate processes.
\- https://elixirschool.com/en/lessons/data_processing/genstage

- входит в стандартную экосистему языка

#### Роли 
- `producer`: обработка входного потока
- `producer_consumer`: выполнение алгоритмов аппроксимации
- `consumer`: печать выходных данных

`[producer] -> [producer_consumer] -> [consumer]`

В доках советуют рассмотреть `ConsumerSupervision`, применимо к данной лабораторной работе он мог бы спавнить процессы с выполнением конкретного алгоритма аппроксимации.
Но в таком случае, чтобы быть полноценным `consumer` ему нужно печать текст, а мы ходим делать это в отдельном "stage". 
Если же спавнить их с ролью `producer_consumer`, то сильно усложняется всё взаимодействие

Может быть, стоит сделать отправку событий по алгоритмам аппроксимации с дублирующим блоком данных, то есть `1 алгоритм` = `1 consumer`
> GenStage.PartitionDispatcher - dispatches all events to a fixed amount of consumers that works as partitions according to a hash function.

Ещё можно сделать весёлый `Broadcast` с пробросом событий.

- https://medium.com/@andreichernykh/elixir-a-few-things-about-genstage-id-wish-to-knew-some-time-ago-b826ca7d48ba

#### Тоже самое, но иначе
- Голые процессы - https://elixirschool.com/en/lessons/intermediate/concurrency#processes-0
- Flow как в Kotlin - https://github.com/dashbitco/flow
- Hype solution - https://elixir-broadway.org/

#### ProducerConsumer State
```elixir

defmodule Lab3.Stage.ProducerConsumer.State do
  @moduledoc """
  Struct to store state.
  """

  alias Lab3.Util.Window

  @enforce_keys [:step, :methods]
  defstruct [:step, :methods]

  def new(step, window),
    do: %__MODULE__{
      step: step,
      methods: %{
        lagrange: Window.new(window),
        linear: Window.new(2)
      }
    }

  def add_point(
        %__MODULE__{
          step: step,
          methods: methods
        },
        point
      ),
      do: %__MODULE__{
        step: step,
        methods:
          Enum.map(methods, fn {method, window} -> {method, Window.push(window, point)} end)
      }
end
```

### Custom Broadway
- https://hexdocs.pm/broadway/architecture.html

Buffer is just like in Kotlin
- https://kotlinlang.org/api/kotlinx.coroutines/kotlinx-coroutines-core/kotlinx.coroutines.flow/buffer.html

### Сборка и запуск
- Когда у есть `Application`, становится больно. Приходится удалять ссылку на модуль в `MixProject` (`mod: {Lab3.Application, []}`), потому что `[]` - это аргументы
```elixir
def application do
    [
      extra_applications: [:logger]
    ]
  end
```

- https://medium.com/blackode/writing-the-command-line-application-in-elixir-78a8d1b1850

Пример:
- `mix escript.build`
- `./lab3 --window 4 --step 0.75`
```
-1.5 -14.1014
-0.75 -0.931596
Method: linear
{-1.5, -14.1014}, {-0.75, -0.931596}
0.75 0.931596
Method: linear
{-0.75, -0.931596}, {0.0, 0.0}, {0.75, 0.931596}
1.5 14.1014
Method: lagrange
{-1.5, -14.1014}, {-0.75, -0.931596}, {0.0, 0.0}, {0.75, 0.931596}, {1.5, 14.1014}
Method: linear
{0.75, 0.931596}, {1.5, 14.1014}
```

### FloatStream
No float range in Elixir :( (and Erlang)
\- https://stackoverflow.com/questions/34383303/range-of-floating-point-numbers

```elixir
defmodule Lab3.Util.FloatStream do
  @spec new(from :: float(), to :: float(), step :: float()) :: Enumerable.t(float())
  def new(from, to, step) do
    from
    |> Stream.iterate(&(&1 + step))
    |> Stream.take_while(&(&1 <= to))
    |> Enum.to_list()
  end
end
```

### Window
```elixir
defmodule Lab3.Util.Window do
  @moduledoc """
  Struct to operate with fixed size list.
  """

  @enforce_keys [:size]
  defstruct [:size, elements: []]

  @type t :: %__MODULE__{}

  @spec new(size :: pos_integer()) :: t()
  def new(size) do
    %__MODULE__{size: size}
  end

  def push(%__MODULE__{size: size, elements: []}, element) do
    %__MODULE__{size: size, elements: [element]}
  end

  def push(%__MODULE__{size: size, elements: elements}, element) when length(elements) < size do
    %__MODULE__{size: size, elements: elements ++ [element]}
  end

  def push(%__MODULE__{size: size, elements: [_ | tail]}, element) do
    %__MODULE__{size: size, elements: tail ++ [element]}
  end

  def full?(%__MODULE__{size: size, elements: elements}), do: length(elements) == size
end
```

### Tests pain
`--step 0.0`
```plain
mix test
Compiling 9 files (.ex)
Generated lab3 app
....Killed
```

## Вывод
В ходе работы познакомился с `GenStage` ...

- https://semaphoreci.com/community/tutorials/a-practical-guide-to-test-doubles-in-elixir