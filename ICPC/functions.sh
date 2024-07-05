#!/bin/bash

# コンパイル用関数
# example:
# compile "A.cpp" "A" "debug"
function compile {
    local source_file=$1
    local output_file=$2
    local debug_flag=$3

    local compile_cmd="g++ -std=c++20 -Wall -O3 -march=native -Wextra -DLOCAL -I ./include"
    if [ "$debug_flag" == "debug" ]; then
        compile_cmd="$compile_cmd -D_GLIBCXX_DEBUG"
    fi
    compile_cmd="$compile_cmd -o $output_file $source_file"

    eval $compile_cmd
    if [ $? -eq 0 ]; then
        echo "[+] Compiled $source_file successfully!"
    else
        echo "[x] Compilation failed for $source_file"
        exit 1
    fi
}

function compile_random {
    local prefix=${1:-random}
    compile "${prefix}.cpp" "${prefix}_" debug
}

function compile_naive {
    local prefix=${1:-naive}
    compile "${prefix}.cpp" "${prefix}_" debug
}

function compile_sol {
    local prefix=${1:-A}
    local debug_flag=$2 # if this is "nodebug", then compile without debug flag
    if [ "$debug_flag" == "nodebug" ]; then
        compile "${prefix}.cpp" "${prefix}"
    else
        compile "${prefix}.cpp" "${prefix}" debug
    fi
}

function debug {
    local trial_count=$1  # 実行するテストケースの回数
    local sol_exec=${2:-"./A"}          # 解答プログラムの実行ファイル名
    local random_exec=${3:-"./random_"} # ランダムテストケース生成プログラムの実行ファイル名
    local naive_exec=${4:-"./naive_"}   # 正解プログラムの実行ファイル名
    local c=0  # テストケースのカウンタ

    # echo exec files
    echo "[i] Executing $sol_exec with $trial_count testcases"
    echo "[i] Random Exec: $random_exec, Naive Exec: $naive_exec"

    # 指定された回数だけテストを繰り返すループ
    while [ $c -lt $trial_count ]; do
        ((c++))  # カウンタをインクリメント

        # ランダムテストケースを生成し、WA_input.txt に出力
        $random_exec > WA_input.txt

        # テストケースの進捗を表示
        echo -ne "\r[i] Running on Testcase $c ..."

        # naive プログラムを実行して正解の出力を取得
        local ans=$($naive_exec < WA_input.txt)
        # check
        if [ $? -ne 0 ]; then
            echo
            echo "[x] Runtime Error in naive (Failed in Case $c)"
            break
        fi

        # 解答プログラムを実行して解答の出力を取得
        local myans=$($sol_exec < WA_input.txt)

        # 解答プログラムが正常に実行されたかをチェック
        if [ $? -ne 0 ]; then
            # 実行が失敗した場合のエラーメッセージ
            echo
            echo "[x] Runtime Error in solution (Failed in Case $c)"
            echo "Correct Answer: $ans"
            break  # ループを終了
        fi

        # 出力の不要な空白を削除して整形
        ans=$(echo "$ans" | tr -s ' ' | sed 's/ *$//')
        myans=$(echo "$myans" | tr -s ' ' | sed 's/ *$//')

        # 正解の出力と解答の出力を比較
        if [ "$myans" != "$ans" ]; then
            # 出力が異なる場合のエラーメッセージ
            echo
            echo "[x] Wrong Answer (Failed in Case $c)"
            echo "Correct Answer: $ans"
            echo "Your Answer: $myans"
            break  # ループを終了
        fi

        # 指定された回数のテストをすべて通過した場合のメッセージ
        if [ $c -eq $trial_count ]; then
            echo
            echo "[+] Passed $trial_count Testcases!"
            break  # ループを終了
        fi
    done
}
