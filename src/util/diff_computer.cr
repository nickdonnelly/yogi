module DiffComputer

  def compute_diff(left : String, right : String) : String
    "something"
  end

  
  private struct Item
    property :startA, :startB, :deletedA, :insertedB

    def initialize(@startA : Int32, @startB : Int32, @deletedA : Int32, @insertedB : Int32)
    end
  end

  private struct ShortedMiddleSnakeReturnData
    getter :x, :y
    def initialize(@x, @y)
    end
  end

  def lcs_len(a : String, b : String, stopping_point max : Int32 = 10_000) : Int32
    if a.size + b.size < max 
      max = a.size + b.size
    end
    v = Array(Int32).new size: (2 * max + 1), value: 0
    d, x, y = 0, 0, 0

    while d <= max
      k = -d
      while k <= d
        if k == -d || (k != d && v[k-1] < v[k+1])
          x = v[k+1]
        else
          x = v[k-1] + 1
        end
        y = x - k

        while x < a.size && y < b.size
          begin
            if a[x+1] == b[y+1]
              x += 1
              y += 1
            end
          rescue
          end
        end

        v[k] = x

        if x >= a.size - 1 && y >= b.size - 1
          return d
        end

        k += 2
      end
      d += 1
    end
    
    max + 1
  end
end
