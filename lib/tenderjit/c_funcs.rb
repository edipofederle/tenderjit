class TenderJIT
  class CFuncs
    include Fiddle

    attr_reader :archive, :encoded_instructions, :instruction_lengths

    class Fiddle::Function
      def to_proc
        this = self
        lambda { |*args| this.call(*args) }
      end
    end unless Function.method_defined?(:to_proc)

    def self.make_function name, args, ret
      ptr = Handle::DEFAULT[name]
      func = Function.new ptr, args, ret, name: name
      define_singleton_method name, &func.to_proc
    end

    PROT_READ   = 0x01
    PROT_WRITE  = 0x02
    PROT_EXEC   = 0x04
    PROT_COPY   = 0x10

    make_function "mach_task_self", [], TYPE_VOIDP
    make_function "vm_protect", [TYPE_VOIDP, -TYPE_INT64_T, TYPE_SIZE_T, TYPE_CHAR, TYPE_INT], TYPE_INT
    make_function "rb_intern", [TYPE_CONST_STRING], TYPE_INT

    def self.mprotect addr, len, prot
      vm_protect mach_task_self, addr, len, 0, prot | PROT_COPY
    end
  end
end
