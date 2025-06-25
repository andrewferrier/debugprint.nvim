local debugprint = require("debugprint")
local support = require("tests.support")

describe("can do basic debug statement insertion", function()
    before_each(function()
        debugprint.setup()
    end)

    after_each(support.teardown)

    it("can debug a C file with __LINE__ and __FILE__", function()
        assert.equals(support.get_notify_message(), nil)

        support.init_file({
            "foo",
            "bar",
        }, "c", 1, 0)

        support.feedkeys("g?p")

        support.check_lines({
            "foo",
            'fprintf(stderr, "DEBUGPRINT[1]: %s:%d (after foo)\\n", __FILE__, __LINE__);',
            "bar",
        })

        assert.equals(support.get_notify_message(), nil)
    end)

    it("can debug a C file with __LINE__ and __FILE__ (variable)", function()
        assert.equals(support.get_notify_message(), nil)

        support.init_file({
            "foo",
            "bar",
        }, "c", 1, 0)

        support.feedkeys("g?v<CR>")

        support.check_lines({
            "foo",
            'fprintf(stderr, "DEBUGPRINT[1]: %s:%d: foo=%d\\n", __FILE__, __LINE__, foo);',
            "bar",
        })

        assert.equals(support.get_notify_message(), nil)
    end)

    it("can debug a C++ file with __LINE__ and __FILE__", function()
        assert.equals(support.get_notify_message(), nil)

        support.init_file({
            "foo",
            "bar",
        }, "cpp", 1, 0)

        support.feedkeys("g?p")

        support.check_lines({
            "foo",
            'std::cerr << "DEBUGPRINT[1]: " << __FILE__ << ":" << __LINE__ << " (after foo)" << std::endl;',
            "bar",
        })

        assert.equals(support.get_notify_message(), nil)
    end)

    it("can debug a C++ file with __LINE__ and __FILE__ (variable)", function()
        assert.equals(support.get_notify_message(), nil)

        support.init_file({
            "foo",
            "bar",
        }, "cpp", 1, 0)

        support.feedkeys("g?v")

        support.check_lines({
            "foo",
            'std::cerr << "DEBUGPRINT[1]: " << __FILE__ << ":" << __LINE__ << ": foo=" << foo << std::endl;',
            "bar",
        })

        assert.equals(support.get_notify_message(), nil)
    end)
end)
