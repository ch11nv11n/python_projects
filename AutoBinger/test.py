import auto_updaters

def main():
    auto_updaters.check_and_update_geckodriver()
    auto_updaters.check_and_update_msdriver()
    
    ...

if __name__ == '__main__':
    main()