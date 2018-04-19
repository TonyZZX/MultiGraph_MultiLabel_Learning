package cn.edu.neu.esm

import java.io.BufferedReader
import java.io.IOException
import java.util.*

/**
 * Multi-Label for Graph
 */
class MultiLabel {
    var multiLabels = ArrayList<Int>()

    @Throws(IOException::class)
    fun read(reader: BufferedReader): BufferedReader {
        val result = ArrayList<String>()
        multiLabels.clear()

        var line = reader.readLine()
        while (line != null) {
            result.clear()
            val splitRead = line.split(" ".toRegex()).dropLastWhile({ it.isEmpty() }).toTypedArray()
            result.addAll(Arrays.asList(*splitRead))

            if (!result.isEmpty()) {
                if (result[0] == "t") {
                    if (!multiLabels.isEmpty()) { // use as delimiter
                        break
                    }
                } else if (result[0] == "l" && result.size >= 3) {
                    val label = Integer.parseInt(result[2])
                    // Positive label reader marked with 1, while negative label reader marked with -1.
                    if (label > 0) {
                        multiLabels.add(1)
                    } else {
                        multiLabels.add(-1)
                    }
                }
            }
            line = reader.readLine()
        }

        return reader
    }
}
