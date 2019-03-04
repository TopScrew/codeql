/**
 * @name Potential buffer overflow
 * @description Using a library function that does not check buffer bounds
 *              requires the surrounding program to be very carefully written
 *              to avoid buffer overflows.
 * @kind problem
 * @id cpp/potential-buffer-overflow
 * @problem.severity warning
 * @tags reliability
 *       security
 *       external/cwe/cwe-676
 * @deprecated This query is deprecated, use
 *             Security/CWE/CWE-120/OverrunWrite.ql and
 *             Security/CWE/CWE-120/OverrunWriteFloat.ql instead.
 */
import cpp
import semmle.code.cpp.commons.Buffer

class SprintfCall extends FunctionCall {
  SprintfCall() {
    this.getTarget().hasName("sprintf") or this.getTarget().hasName("vsprintf")
  }

  int getBufferSize() {
    result = getBufferSize(this.getArgument(0), _)
  }

  int getMaxConvertedLength() {
    result = this.getArgument(1).(FormatLiteral).getMaxConvertedLength()
  }

  predicate isDangerous() {
    this.getMaxConvertedLength() > this.getBufferSize()
  }

  string getDescription() {
    result = "This conversion may yield a string of length "+this.getMaxConvertedLength().toString()+
             ", which exceeds the allocated buffer size of "+this.getBufferSize().toString()
  }
}

from SprintfCall c
where c.isDangerous()
select c, c.getDescription()
