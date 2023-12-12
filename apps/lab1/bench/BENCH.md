Benchmark

Benchmark run from 2023-12-12 19:58:28.420572Z UTC

## System

Benchmark suite executing on the following system:

<table style="width: 1%">
  <tr>
    <th style="width: 1%; white-space: nowrap">Operating System</th>
    <td>Linux</td>
  </tr><tr>
    <th style="white-space: nowrap">CPU Information</th>
    <td style="white-space: nowrap">Intel(R) Core(TM) i7-10510U CPU @ 1.80GHz</td>
  </tr><tr>
    <th style="white-space: nowrap">Number of Available Cores</th>
    <td style="white-space: nowrap">8</td>
  </tr><tr>
    <th style="white-space: nowrap">Available Memory</th>
    <td style="white-space: nowrap">7.47 GB</td>
  </tr><tr>
    <th style="white-space: nowrap">Elixir Version</th>
    <td style="white-space: nowrap">1.15.0</td>
  </tr><tr>
    <th style="white-space: nowrap">Erlang Version</th>
    <td style="white-space: nowrap">26.1</td>
  </tr>
</table>

## Configuration

Benchmark suite executing with the following configuration:

<table style="width: 1%">
  <tr>
    <th style="width: 1%">:time</th>
    <td style="white-space: nowrap">3 s</td>
  </tr><tr>
    <th>:parallel</th>
    <td style="white-space: nowrap">1</td>
  </tr><tr>
    <th>:warmup</th>
    <td style="white-space: nowrap">2 s</td>
  </tr>
</table>

## Statistics

__Input: Bigger__

Run Time

<table style="width: 1%">
  <tr>
    <th>Name</th>
    <th style="text-align: right">IPS</th>
    <th style="text-align: right">Average</th>
    <th style="text-align: right">Devitation</th>
    <th style="text-align: right">Median</th>
    <th style="text-align: right">99th&nbsp;%</th>
  </tr>

  <tr>
    <td style="white-space: nowrap">foldl</td>
    <td style="white-space: nowrap; text-align: right">1.13 K</td>
    <td style="white-space: nowrap; text-align: right">0.88 ms</td>
    <td style="white-space: nowrap; text-align: right">&plusmn;40.09%</td>
    <td style="white-space: nowrap; text-align: right">0.73 ms</td>
    <td style="white-space: nowrap; text-align: right">2.18 ms</td>
  </tr>

  <tr>
    <td style="white-space: nowrap">foldr</td>
    <td style="white-space: nowrap; text-align: right">0.41 K</td>
    <td style="white-space: nowrap; text-align: right">2.47 ms</td>
    <td style="white-space: nowrap; text-align: right">&plusmn;22.66%</td>
    <td style="white-space: nowrap; text-align: right">2.32 ms</td>
    <td style="white-space: nowrap; text-align: right">4.75 ms</td>
  </tr>

</table>


Run Time Comparison

<table style="width: 1%">
  <tr>
    <th>Name</th>
    <th style="text-align: right">IPS</th>
    <th style="text-align: right">Slower</th>
  <tr>
    <td style="white-space: nowrap">foldl</td>
    <td style="white-space: nowrap;text-align: right">1.13 K</td>
    <td>&nbsp;</td>
  </tr>

  <tr>
    <td style="white-space: nowrap">foldr</td>
    <td style="white-space: nowrap; text-align: right">0.41 K</td>
    <td style="white-space: nowrap; text-align: right">2.79x</td>
  </tr>

</table>




__Input: Medium__

Run Time

<table style="width: 1%">
  <tr>
    <th>Name</th>
    <th style="text-align: right">IPS</th>
    <th style="text-align: right">Average</th>
    <th style="text-align: right">Devitation</th>
    <th style="text-align: right">Median</th>
    <th style="text-align: right">99th&nbsp;%</th>
  </tr>

  <tr>
    <td style="white-space: nowrap">foldl</td>
    <td style="white-space: nowrap; text-align: right">13.32 K</td>
    <td style="white-space: nowrap; text-align: right">75.08 &micro;s</td>
    <td style="white-space: nowrap; text-align: right">&plusmn;33.06%</td>
    <td style="white-space: nowrap; text-align: right">67.34 &micro;s</td>
    <td style="white-space: nowrap; text-align: right">138.04 &micro;s</td>
  </tr>

  <tr>
    <td style="white-space: nowrap">foldr</td>
    <td style="white-space: nowrap; text-align: right">4.00 K</td>
    <td style="white-space: nowrap; text-align: right">249.85 &micro;s</td>
    <td style="white-space: nowrap; text-align: right">&plusmn;28.76%</td>
    <td style="white-space: nowrap; text-align: right">234.28 &micro;s</td>
    <td style="white-space: nowrap; text-align: right">561.24 &micro;s</td>
  </tr>

</table>


Run Time Comparison

<table style="width: 1%">
  <tr>
    <th>Name</th>
    <th style="text-align: right">IPS</th>
    <th style="text-align: right">Slower</th>
  <tr>
    <td style="white-space: nowrap">foldl</td>
    <td style="white-space: nowrap;text-align: right">13.32 K</td>
    <td>&nbsp;</td>
  </tr>

  <tr>
    <td style="white-space: nowrap">foldr</td>
    <td style="white-space: nowrap; text-align: right">4.00 K</td>
    <td style="white-space: nowrap; text-align: right">3.33x</td>
  </tr>

</table>




__Input: Small__

Run Time

<table style="width: 1%">
  <tr>
    <th>Name</th>
    <th style="text-align: right">IPS</th>
    <th style="text-align: right">Average</th>
    <th style="text-align: right">Devitation</th>
    <th style="text-align: right">Median</th>
    <th style="text-align: right">99th&nbsp;%</th>
  </tr>

  <tr>
    <td style="white-space: nowrap">foldl</td>
    <td style="white-space: nowrap; text-align: right">90.91 K</td>
    <td style="white-space: nowrap; text-align: right">11.00 &micro;s</td>
    <td style="white-space: nowrap; text-align: right">&plusmn;847.11%</td>
    <td style="white-space: nowrap; text-align: right">7.27 &micro;s</td>
    <td style="white-space: nowrap; text-align: right">28.68 &micro;s</td>
  </tr>

  <tr>
    <td style="white-space: nowrap">foldr</td>
    <td style="white-space: nowrap; text-align: right">45.82 K</td>
    <td style="white-space: nowrap; text-align: right">21.83 &micro;s</td>
    <td style="white-space: nowrap; text-align: right">&plusmn;89.00%</td>
    <td style="white-space: nowrap; text-align: right">20.32 &micro;s</td>
    <td style="white-space: nowrap; text-align: right">33.11 &micro;s</td>
  </tr>

</table>


Run Time Comparison

<table style="width: 1%">
  <tr>
    <th>Name</th>
    <th style="text-align: right">IPS</th>
    <th style="text-align: right">Slower</th>
  <tr>
    <td style="white-space: nowrap">foldl</td>
    <td style="white-space: nowrap;text-align: right">90.91 K</td>
    <td>&nbsp;</td>
  </tr>

  <tr>
    <td style="white-space: nowrap">foldr</td>
    <td style="white-space: nowrap; text-align: right">45.82 K</td>
    <td style="white-space: nowrap; text-align: right">1.98x</td>
  </tr>

</table>