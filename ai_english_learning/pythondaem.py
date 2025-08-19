import sys

# 增加递归深度限制，这是一个好习惯
sys.setrecursionlimit(2000)

def solve(n, m, q):
    """
    处理单个测试案例的函数。
    接收 n, m, q 作为参数，然后读取该案例剩余的输入。
    """
    # --- 1. 读取本案例的剩余输入 ---
    try:
        start_x, start_y = map(int, sys.stdin.readline().split())
        start_x -= 1
        start_y -= 1

        grid = []
        for _ in range(n):
            # 读取一行，如果为空则说明输入提前结束
            line = sys.stdin.readline()
            if not line: break
            grid.append(list(map(int, line.split())))
        
        # 确保 grid 被正确读取
        if len(grid) != n:
            # 输入格式不完整，可以选择静默退出或报错
            return
            
    except (IOError, ValueError):
        # 如果在读取过程中发生错误，则终止此案例的处理
        return

    # --- 2. 初始化解题状态 ---
    visited = [[False for _ in range(n)] for _ in range(n)]
    solution_count = 0
    directions = [(-1, 0), (1, 0), (0, -1), (0, 1)]

    # --- 3. 定义并执行 DFS ---
    def dfs(x, y, steps, current_rem):
        nonlocal solution_count
        if steps == m:
            if current_rem == 0:
                solution_count += 1
            return

        for dx, dy in directions:
            next_x, next_y = x + dx, y + dy
            if 0 <= next_x < n and 0 <= next_y < n and not visited[next_x][next_y]:
                visited[next_x][next_y] = True
                next_rem = (current_rem * 10 + grid[next_x][next_y]) % q
                dfs(next_x, next_y, steps + 1, next_rem)
                visited[next_x][next_y] = False

    visited[start_x][start_y] = True
    initial_rem = grid[start_x][start_y] % q
    dfs(start_x, start_y, 0, initial_rem)

    # --- 4. 输出本案例的结果 ---
    print(solution_count)

def main():
    """
    主函数，循环读取并处理多个测试案例。
    """
    while True:
        # <--- 关键改动: 尝试读取新案例的第一行
        first_line = sys.stdin.readline()

        # <--- 关键改动: 如果读到的是空行 (EOF)，说明所有输入都已处理完毕
        if not first_line:
            break

        # 如果读到了内容，就解析并调用 solve 函数
        try:
            n, m, q = map(int, first_line.split())
            solve(n, m, q)
        except (IOError, ValueError):
            # 如果第一行格式不正确，则终止
            break

# 程序的入口点
if __name__ == "__main__":
    main()


import sys

def solve():
    """
    Solves the "Xiao A Deletes Numbers" problem.
    """
    try:
        # 读取声称的数组大小
        n_str = sys.stdin.readline()
        if not n_str:
            return
        # 我们不再需要 n, 但为了完整性先读一下
        # n = int(n_str)

        # 读取实际的数组元素
        a = list(map(int, sys.stdin.readline().split()))
    except (IOError, ValueError):
        return

    # --- 修改部分：使用列表 a 的实际长度 ---
    actual_n = len(a)

    if actual_n <= 2:
        print(0)
        return

    max_len = 0
    if actual_n > 0:
      max_len = 1
    
    # --- Pass 1: Find the longest contiguous non-decreasing subarray ---
    current_len = 1
    # 使用 a 的实际长度来循环
    for i in range(1, actual_n):
        if a[i] >= a[i - 1]:
            current_len += 1
        else:
            max_len = max(max_len, current_len)
            current_len = 1
    max_len = max(max_len, current_len)

    # --- Pass 2: Find the longest contiguous non-increasing subarray ---
    current_len = 1
    # 使用 a 的实际长度来循环
    for i in range(1, actual_n):
        if a[i] <= a[i - 1]:
            current_len += 1
        else:
            max_len = max(max_len, current_len)
            current_len = 1
    max_len = max(max_len, current_len)
    
    # --- Final Calculation ---
    # 使用 a 的实际长度来判断
    if max_len == actual_n:
        print(actual_n - 1)
    else:
        print(actual_n - max_len)


# Run the solution
if __name__ == "__main__":
    solve()